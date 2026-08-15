'use strict'
/**
 * 财小橙 · user-center 云函数
 * ------------------------------------------------------------
 * 职责：仅负责【学习进度】的云端存取。
 * 登录/登出/短信验证码等账号操作由官方 uni-id-co 云对象负责（见 backend/README.md）。
 *
 * 本函数只暴露两个 action：
 *   saveProgress   params: { progress }
 *   getProgress    params: {}
 *
 * 鉴权：用 uni-id-common.checkToken(event.uniIdToken) 校验登录态。
 *      （uniCloud 客户端会自动把 uni-id token 放入 event.uniIdToken）
 *
 * 依赖公共模块：uni-id-common（HBuilderX 安装，见 backend/README.md）
 * 数据库：cxch-user-progress（按 uid 关联，仅本人可读写）
 */
const uniIdCommon = require('uni-id-common')
const db = uniCloud.database()

const PROGRESS_COLL = 'cxch-user-progress'

exports.main = async (event) => {
  const action = event.action
  const params = event.params || {}

  // 校验登录态：uni-id-co 登录后客户端自动带 uniIdToken
  const uniID = uniIdCommon.createInstance({ clientInfo: event })
  const token = event.uniIdToken
  if (!token) return { errCode: 401, errMsg: '未登录' }

  let payload
  try {
    payload = await uniID.checkToken(token)
  } catch (e) {
    return { errCode: 401, errMsg: 'token 校验失败' }
  }
  if (payload.errCode && payload.errCode !== 0) {
    return { errCode: 401, errMsg: payload.errMsg || '登录已过期' }
  }
  const uid = payload.uid

  try {
    switch (action) {
      case 'saveProgress':
        return await saveProgress(uid, params.progress)
      case 'getProgress':
        return await getProgress(uid)
      default:
        return { errCode: 404, errMsg: '未知 action: ' + action }
    }
  } catch (e) {
    console.error('[user-center]', action, (e && e.stack) || e)
    return { errCode: 500, errMsg: (e && e.message) || '服务异常' }
  }
}

/** 上传进度（覆盖该 uid 的记录）。 */
async function saveProgress(uid, progress) {
  if (!progress) return { errCode: 1, errMsg: 'progress 不能为空' }
  const now = Date.now()
  const exist = await db.collection(PROGRESS_COLL).where({ uid }).limit(1).get()
  if (exist.data && exist.data.length) {
    await db.collection(PROGRESS_COLL).doc(exist.data[0]._id).update({ progress, updated_at: now })
  } else {
    await db.collection(PROGRESS_COLL).add({ uid, progress, updated_at: now })
  }
  return { errCode: 0, updated_at: now }
}

/** 拉取进度。 */
async function getProgress(uid) {
  const r = await db.collection(PROGRESS_COLL).where({ uid }).limit(1).get()
  const doc = r.data && r.data[0]
  return { errCode: 0, progress: (doc && doc.progress) || null, updated_at: (doc && doc.updated_at) || 0 }
}
