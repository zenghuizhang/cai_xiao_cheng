/**
 * 用户系统 Store —— 登录态 + 云端进度同步。
 *
 * 设计：本地优先。未登录时 App 完全可用（游客模式）；登录后跨设备同步。
 * 登录方式：
 *   - 微信小程序：openid 登录（uni.login→code→云函数 loginByWeixin）
 *   - 微信小程序：手机号一键登录（button open-type=getPhoneNumber→code→云函数）
 *   - H5 / 通用：短信验证码登录（sendSmsCode + loginBySmsCode）
 *
 * 同步策略：本地写即存 → debounce 3s 上云；登录/启动 → 拉取云端 → 合并（数值取大、列表取并集）。
 *
 * 注：manifest.json 的 uniCloud spaceId 为空时，云函数不可用，
 *     所有云调用会走 catch 分支并给出友好提示，App 仍以本地模式运行。
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
    cloudAvailable: true, // 云端是否可用（首次调用失败后置 false，避免反复试）
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
        // 拉取云端进度合并（异步，不阻塞）
        this.pullProgress().catch(() => {})
      }
      // 监听 app store 进度变更 → debounce 上云
      uni.$on('progress-changed', () => {
        if (!this.isLoggedIn) return
        if (syncTimer) clearTimeout(syncTimer)
        syncTimer = setTimeout(() => {
          this.syncProgress().catch(() => {})
        }, 3000)
      })
    },

    /** 调用云函数 user-center 的统一封装。 */
    async _call(action, params = {}) {
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
        const r = await this._call('loginByWeixin', { code })
        this._applyLoginResult(r)
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
        const r = await this._call('loginByPhone', { phoneCode })
        this._applyLoginResult(r)
        await this.pullProgress()
        return true
      } finally {
        this.loginLoading = false
      }
    },

    /** 通用/H5：发送短信验证码。 */
    async sendSmsCode(phone) {
      await this._call('sendSmsCode', { phone })
      return true
    },

    /** 通用/H5：短信验证码登录。 */
    async loginBySmsCode(phone, code) {
      this.loginLoading = true
      try {
        const r = await this._call('loginBySmsCode', { phone, code })
        this._applyLoginResult(r)
        await this.pullProgress()
        return true
      } finally {
        this.loginLoading = false
      }
    },

    /** 写入登录态到 store + 本地。 */
    _applyLoginResult(r) {
      this.token = r.token || ''
      this.userInfo = {
        uid: r.uid || '',
        nickname: r.nickname || r.userInfo?.nickname || '同学',
        avatar: r.avatar || r.userInfo?.avatar || '',
        username: r.username || r.userInfo?.username || '',
      }
      this.isLoggedIn = true
      this.cloudAvailable = true
      set(KEYS.TOKEN, this.token)
      set(KEYS.USERINFO, this.userInfo)
    },

    /** 登出（保留本地进度，清云端登录态）。 */
    async logout() {
      try {
        if (this.isLoggedIn) await this._call('logout', {})
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
      const app = useAppStore()
      const local = getProgress()
      this.syncing = true
      try {
        await this._call('saveProgress', { progress: local })
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
        const r = await this._call('getProgress', {})
        const cloud = r.progress || null
        const merged = mergeProgress(local, cloud)
        app.applyMergedProgress(merged)
        // 合并后回写本地 + 上云一次（保证云端也有并集）
        await this._call('saveProgress', { progress: merged }).catch(() => {})
      } catch (e) {
        this._markCloudUnavailable(e)
      } finally {
        this.syncing = false
      }
    },

    /** 云端不可用时静默降级，避免每次操作都报错。 */
    _markCloudUnavailable(e) {
      const msg = (e && e.message) || ''
      if (/spaceId|空间|未关联|FUNCTIONS_NOT_FOUND|not found|无响应/i.test(msg)) {
        this.cloudAvailable = false
      }
      console.warn('[user] cloud sync failed:', msg)
    },
  },
})
