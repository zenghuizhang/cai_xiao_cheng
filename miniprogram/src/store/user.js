/**
 * 用户系统 Store —— 登录态 + 云端进度同步。
 *
 * 架构分工：
 *   - 登录/登出/短信验证码 → 官方 uni-id-co 云对象（uniCloud.importObject('uni-id-co')）
 *   - 学习进度存取 → 自建 user-center 云函数（uniCloud.callFunction）
 *
 * 登录方式：
 *   - 微信小程序：openid 登录（uni.login→code→uniIdCo.loginByWeixin）
 *   - 微信小程序：手机号一键登录（getPhoneNumber→phoneCode→uniIdCo.loginByWeixinMobile）
 *   - H5 / 通用：短信验证码登录（uniIdCo.sendSmsCode + uniIdCo.loginBySms，需图形验证码 captcha）
 *
 * 同步策略：本地写即存 → debounce 3s 上云；登录/启动 → 拉取云端 → 合并（数值取大、列表取并集）。
 *
 * 注：manifest.json 的 uniCloud spaceId 为空时，云调用不可用，App 以本地游客模式运行。
 */
import { defineStore } from 'pinia'
import { KEYS, get, set, remove, getProgress } from '@/utils/storage'
import { RANK_TITLES, useAppStore } from './app'

/** 合并两份进度：数值取大、列表取并集、记录按 key 合并（passed 优先 / ts 取新）。 */
export function mergeProgress(local, cloud) {
  if (!cloud) return local
  const l = local || {}
  const c = cloud
  const union = (a, b) => Array.from(new Set([...(a || []), ...(b || [])]))
  const maxLevel = Math.max(l.current_level || 1, c.current_level || 1)
  return {
    onboarding_done: !!(l.onboarding_done || c.onboarding_done),
    total_points: Math.max(l.total_points || 0, c.total_points || 0),
    current_level: maxLevel,
    rank_title: RANK_TITLES[maxLevel] || l.rank_title || '青铜小白',
    cards_read: union(l.cards_read, c.cards_read),
    passed_chapters: union(l.passed_chapters, c.passed_chapters),
    review_queue: union(l.review_queue, c.review_queue),
    mastered_cards: union(l.mastered_cards, c.mastered_cards),
    unlocked_fruits: union(l.unlocked_fruits, c.unlocked_fruits),
    crash_used: !!(l.crash_used || c.crash_used),
    risk_profile: c.risk_profile || l.risk_profile || null,
    daily_streak: Math.max(l.daily_streak || 0, c.daily_streak || 0),
    last_daily_date:
      (l.last_daily_date || '') >= (c.last_daily_date || '')
        ? l.last_daily_date || ''
        : c.last_daily_date || '',
    quiz_records: mergeRecords(l.quiz_records, c.quiz_records),
    sim_records: mergeRecords(l.sim_records, c.sim_records),
    daily_records: mergeRecords(l.daily_records, c.daily_records),
    updated_at: Math.max(l.updated_at || 0, c.updated_at || 0),
  }
}

function mergeRecords(a, b) {
  a = a || {}
  b = b || {}
  const out = { ...a }
  for (const k of Object.keys(b)) {
    const av = out[k]
    const bv = b[k]
    if (!av) {
      out[k] = bv
      continue
    }
    if (!bv) continue
    if (bv.passed && !av.passed) out[k] = bv
    else if (av.passed && !bv.passed) out[k] = av
    else out[k] = (bv.ts || 0) > (av.ts || 0) ? bv : av
  }
  return out
}

let syncTimer = null

export const useUserStore = defineStore('user', {
  state: () => ({
    isLoggedIn: false,
    userInfo: null, // { uid, nickname, avatar, username }
    token: '',
    loginLoading: false,
    syncing: false,
    cloudAvailable: true,
  }),

  getters: {
    nickname: (s) => (s.userInfo && s.userInfo.nickname) || '同学',
    avatar: (s) => (s.userInfo && s.userInfo.avatar) || '',
    uid: (s) => (s.userInfo && s.userInfo.uid) || '',
  },

  actions: {
    /** 恢复本地登录态 + 注册进度变更监听。 */
    init() {
      const token = get(KEYS.TOKEN, '')
      const userInfo = get(KEYS.USERINFO, null)
      if (token && userInfo) {
        this.token = token
        this.userInfo = userInfo
        this.isLoggedIn = true
        this.pullProgress().catch(() => {})
      }
      uni.$on('progress-changed', () => {
        if (!this.isLoggedIn) return
        if (syncTimer) clearTimeout(syncTimer)
        syncTimer = setTimeout(() => {
          this.syncProgress().catch(() => {})
        }, 3000)
      })
    },

    /** 获取 uni-id-co 云对象实例。 */
    _uniIdCo() {
      return uniCloud.importObject('uni-id-co')
    },

    /** 调用 user-center 云函数（仅用于进度同步）。 */
    async _callUserCenter(action, params = {}) {
      const res = await uniCloud.callFunction({
        name: 'user-center',
        data: { action, params },
      })
      const r = res && res.result
      if (!r) throw new Error('云端无响应')
      if (r.errCode && r.errCode !== 0) {
        throw new Error(r.errMsg || '操作失败')
      }
      return r
    },

    /** 微信小程序：openid 登录。 */
    async loginByWeixin() {
      this.loginLoading = true
      try {
        const loginRes = await uni.login({ provider: 'weixin' })
        const code = loginRes.code
        if (!code) throw new Error('未获取到微信登录凭证')
        const r = await this._uniIdCo().loginByWeixin({ code })
        this._applyLoginResult(r)
        await this._fetchAccountInfo()
        await this.pullProgress()
        return true
      } finally {
        this.loginLoading = false
      }
    },

    /** 微信小程序：手机号一键登录（getPhoneNumber 的 code）。 */
    async loginByPhone(phoneCode) {
      this.loginLoading = true
      try {
        const r = await this._uniIdCo().loginByWeixinMobile({ phoneCode })
        this._applyLoginResult(r)
        await this._fetchAccountInfo()
        await this.pullProgress()
        return true
      } finally {
        this.loginLoading = false
      }
    },

    /** 获取图形验证码（短信登录前置）。返回 { captchaBase64 }。 */
    async getCaptcha() {
      return await this._uniIdCo().createCaptcha({ scene: 'login-by-sms' })
    },

    /** 通用/H5：发送短信验证码（需图形验证码 captcha）。 */
    async sendSmsCode(phone, captcha) {
      await this._uniIdCo().sendSmsCode({ mobile: phone, captcha, scene: 'login-by-sms' })
      return true
    },

    /** 通用/H5：短信验证码登录。 */
    async loginBySmsCode(phone, code, captcha) {
      this.loginLoading = true
      try {
        const r = await this._uniIdCo().loginBySms({ mobile: phone, code, captcha })
        this._applyLoginResult(r)
        await this._fetchAccountInfo()
        await this.pullProgress()
        return true
      } finally {
        this.loginLoading = false
      }
    },

    /** 写入登录态到 store + 本地。uni-id-co 返回 newToken:{ token, tokenExpired }。 */
    _applyLoginResult(r) {
      const token = (r.newToken && r.newToken.token) || r.token || ''
      this.token = token
      this.userInfo = {
        uid: r.uid || '',
        nickname: (r.userInfo && r.userInfo.nickname) || r.nickname || '同学',
        avatar: (r.userInfo && r.userInfo.avatar) || r.avatar || '',
        username: (r.userInfo && r.userInfo.username) || r.username || '',
      }
      this.isLoggedIn = true
      this.cloudAvailable = true
      set(KEYS.TOKEN, this.token)
      set(KEYS.USERINFO, this.userInfo)
    },

    /** 登录后拉取用户资料（昵称/头像）。 */
    async _fetchAccountInfo() {
      try {
        const r = await this._uniIdCo().getAccountInfo()
        if (r && !r.errCode) {
          const info = r.userInfo || r
          this.userInfo = {
            uid: this.userInfo.uid || info._id || info.uid || '',
            nickname: info.nickname || info.username || this.userInfo.nickname,
            avatar: info.avatar || this.userInfo.avatar,
            username: info.username || this.userInfo.username,
          }
          set(KEYS.USERINFO, this.userInfo)
        }
      } catch (e) {
        /* 忽略，登录结果里已有基础信息 */
      }
    },

    /** 登出。 */
    async logout() {
      try {
        if (this.isLoggedIn) await this._uniIdCo().logout()
      } catch (e) {
        /* ignore */
      }
      this.token = ''
      this.userInfo = null
      this.isLoggedIn = false
      remove(KEYS.TOKEN)
      remove(KEYS.USERINFO)
    },

    /** 上传本地进度到云端。 */
    async syncProgress() {
      if (!this.isLoggedIn) return
      const local = getProgress()
      this.syncing = true
      try {
        await this._callUserCenter('saveProgress', { progress: local })
      } catch (e) {
        this._markCloudUnavailable(e)
      } finally {
        this.syncing = false
      }
    },

    /** 拉取云端进度并与本地合并。 */
    async pullProgress() {
      if (!this.isLoggedIn) return
      const app = useAppStore()
      const local = getProgress()
      this.syncing = true
      try {
        const r = await this._callUserCenter('getProgress', {})
        const cloud = r.progress || null
        const merged = mergeProgress(local, cloud)
        app.applyMergedProgress(merged)
        await this._callUserCenter('saveProgress', { progress: merged }).catch(() => {})
      } catch (e) {
        this._markCloudUnavailable(e)
      } finally {
        this.syncing = false
      }
    },

    /** 云端不可用时静默降级。 */
    _markCloudUnavailable(e) {
      const msg = (e && e.message) || ''
      if (/spaceId|空间|未关联|FUNCTIONS_NOT_FOUND|not found|无响应/i.test(msg)) {
        this.cloudAvailable = false
      }
      console.warn('[user] cloud sync failed:', msg)
    },
  },
})
