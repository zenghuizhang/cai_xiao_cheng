'use strict'
/**
 * 财小橙 · 用户中心云函数
 * ------------------------------------------------------------
 * 统一入口，前端通过 uniCloud.callFunction({ name:'user-center', data:{ action, params } }) 调用。
 *
 * 支持的 action：
 *   loginByWeixin   微信小程序 openid 登录        params: { code }
 *   loginByPhone    微信小程序手机号一键登录      params: { phoneCode }   (button getPhoneNumber 的 code)
 *   sendSmsCode     发送短信验证码（H5/通用）      params: { phone }
 *   loginBySmsCode  短信验证码登录                params: { phone, code }
 *   saveProgress    上传本地进度到云端             params: { progress }
 *   getProgress     拉取云端进度                   params: {}
 *   logout          退出登录                       params: {}
 *
 * 依赖（公共模块，需在 HBuilderX「管理公共模块依赖」中勾选，或下载到 common/）：
 *   - uni-id-common      账号体系（登录/发token/校验）
 *   - uni-config-center  读取 uni-id 配置（common/uni-config-center/uni-id/config.json）
 *
 * 数据库：
 *   - uni-id-users            uni-id 内置用户表（uni-admin 可直接管理）
 *   - cxch-user-progress      学习进度表（按 uid 关联，仅本人可读写）
 *
 * 注意：本函数不直接处理任何交易/金融数据，仅同步学习进度，符合「纯教育」定位。
 */
const uniIdCommon = require('uni-id-common')
const db = uniCloud.database()
const _ = db.command

const PROGRESS_COLL = 'cxch-user-progress'

exports.main = async (event, context) => {
  const action = event.action
  const params = event.params || {}
  // uniCloud 会把客户端信息注入 event；createInstance 用于读取 token、clientInfo
  const uniID = uniIdCommon.createInstance({
    clientInfo: (event.clientInfo ? { clientInfo: event.clientInfo } : event),
  })

  try {
    switch (action) {
      case 'loginByWeixin':
        return await loginByWeixin(uniID, params)
      case 'loginByPhone':
        return await loginByPhone(uniID, params)
      case 'sendSmsCode':
        return await sendSmsCode(uniID, params)
      case 'loginBySmsCode':
        return await loginBySmsCode(uniID, params)
      case 'saveProgress':
        return await saveProgress(uniID, params)
      case 'getProgress':
        return await getProgress(uniID, params)
      case 'logout':
        return await logout(uniID, params)
      default:
        return { errCode: 404, errMsg: '未知 action: ' + action }
    }
  } catch (e) {
    console.error('[user-center]', action, (e && e.stack) || e)
    return { errCode: 500, errMsg: (e && e.errMsg) || (e && e.message) || '服务异常，请稍后再试' }
  }
}

/* ----------------------------- 登录相关 ----------------------------- */

/** 微信小程序：openid 登录（首次自动注册）。 */
async function loginByWeixin(uniID, { code }) {
  if (!code) return { errCode: 1001, errMsg: '缺少微信登录凭证 code' }
  const res = await uniID.loginByWeixin({ code })
  if (res.errCode && res.errCode !== 0) return res
  return normalizeLogin(res)
}

/**
 * 微信小程序：手机号一键登录。
 * 流程：phoneCode → getPhoneNumberByMpWeixin 换手机号 → 查/建用户 → createToken。
 */
async function loginByPhone(uniID, { phoneCode }) {
  if (!phoneCode) return { errCode: 1002, errMsg: '缺少手机号凭证 phoneCode' }
  // 1) 用 getPhoneNumber 的 code 换取真实手机号
  const phoneRes = await uniID.getPhoneNumberByMpWeixin({ code: phoneCode })
  if (phoneRes.errCode && phoneRes.errCode !== 0) return phoneRes
  const phone = phoneRes.phoneNumber || phoneRes.phone
  if (!phone) return { errCode: 1003, errMsg: '未获取到手机号' }
  // 2) 查找或创建用户
  const uid = await ensureUserByMobile(phone)
  // 3) 签发 token
  const tokenRes = await uniID.createToken({ uid })
  if (tokenRes.errCode && tokenRes.errCode !== 0) return tokenRes
  return normalizeLogin({ ...tokenRes, uid, mobile: phone })
}

/** 发送短信验证码（需在 uniCloud 控制台开通 uni-ic 短信服务并配置签名/模板）。 */
async function sendSmsCode(uniID, { phone }) {
  if (!/^1\d{10}$/.test(phone)) return { errCode: 1004, errMsg: '手机号格式不正确' }
  const res = await uniID.sendSmsCode({ mobile: phone, scene: 'login-by-sms' })
  return res
}

/** 短信验证码登录（uni-id 默认在用户不存在时自动注册）。 */
async function loginBySmsCode(uniID, { phone, code }) {
  if (!phone || !code) return { errCode: 1005, errMsg: '手机号或验证码缺失' }
  const res = await uniID.loginBySms({ mobile: phone, code, scene: 'login-by-sms' })
  if (res.errCode && res.errCode !== 0) return res
  return normalizeLogin(res)
}

/** 退出登录（吊销当前 token）。 */
async function logout(uniID) {
  const res = await uniID.logout()
  return { errCode: 0, ...(res || {}) }
}

/**
 * 按手机号查找用户；不存在则创建（不设密码，走验证码/微信体系）。
 * 返回 uid。
 */
async function ensureUserByMobile(phone) {
  const found = await db
    .collection('uni-id-users')
    .where({ mobile: phone })
    .limit(1)
    .get()
  if (found.data && found.data.length) return found.data[0]._id
  const now = Date.now()
  const ins = await db.collection('uni-id-users').add({
    mobile: phone,
    username: phone,
    nickname: '同学',
    role: [],
    register_date: now,
    last_login_date: now,
  })
  return ins.id
}

/* ----------------------------- 进度同步 ----------------------------- */

/** 上传本地进度到云端（覆盖该 uid 的进度记录）。 */
async function saveProgress(uniID, { progress }) {
  const uid = await getUid(uniID)
  if (!uid) return { errCode: 401, errMsg: '未登录或登录已过期' }
  const now = Date.now()
  const exist = await db
    .collection(PROGRESS_COLL)
    .where({ uid })
    .limit(1)
    .get()
  if (exist.data && exist.data.length) {
    await db
      .collection(PROGRESS_COLL)
      .doc(exist.data[0]._id)
      .update({ progress, updated_at: now })
  } else {
    await db.collection(PROGRESS_COLL).add({ uid, progress, updated_at: now })
  }
  return { errCode: 0, updated_at: now }
}

/** 拉取云端进度。 */
async function getProgress(uniID) {
  const uid = await getUid(uniID)
  if (!uid) return { errCode: 401, errMsg: '未登录或登录已过期' }
  const r = await db
    .collection(PROGRESS_COLL)
    .where({ uid })
    .limit(1)
    .get()
  const doc = r.data && r.data[0]
  return { errCode: 0, progress: (doc && doc.progress) || null, updated_at: (doc && doc.updated_at) || 0 }
}

/* ----------------------------- 工具函数 ----------------------------- */

/** 校验当前 token，返回 uid（无效返回 null）。 */
async function getUid(uniID) {
  try {
    const payload = await uniID.checkToken()
    if (payload && payload.errCode && payload.errCode !== 0) return null
    return (payload && payload.uid) || null
  } catch (e) {
    return null
  }
}

/** 把 uni-id 登录结果归一化为前端 _applyLoginResult 期望的字段。 */
function normalizeLogin(res) {
  const userInfo = res.userInfo || null
  return {
    errCode: 0,
    uid: res.uid,
    token: res.token,
    tokenExpired: res.tokenExpired,
    nickname: (userInfo && userInfo.nickname) || res.nickname || '同学',
    avatar: (userInfo && userInfo.avatar) || res.avatar || '',
    username: (userInfo && userInfo.username) || res.username || '',
    mobile: res.mobile || (userInfo && userInfo.mobile) || '',
    userInfo,
  }
}
