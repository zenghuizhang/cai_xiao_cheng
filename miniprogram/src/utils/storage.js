/**
 * 本地存储封装（基于 uni.*StorageSync）。
 * 负责学习进度持久化 + 云端登录态缓存。
 */

export const KEYS = {
  PROGRESS: 'cxch_progress', // 学习进度（本地优先，登录后云端同步）
  TOKEN: 'cxch_token', // uni-id 云端 token
  USERINFO: 'cxch_userinfo', // 云端用户信息（uid/nickname/avatar）
}

/** 进度默认值；新增字段时旧用户也能拿到默认值。 */
export function defaultProgress() {
  return {
    onboarding_done: false,
    total_points: 0,
    current_level: 1,
    rank_title: '青铜小白',
    cards_read: [], // 已读卡片 id
    passed_chapters: [], // 已通关章节 id
    quiz_records: {}, // { chapterId: { correct, total, passed, ts } }
    sim_records: {}, // { simId: { key, pnl, ts } }
    daily_records: {}, // { dateKey: { correct, total, ts } }
    daily_streak: 0,
    last_daily_date: '', // yyyy-mm-dd
    crash_used: false,
    risk_profile: null, // conservative | balanced | aggressive
    review_queue: [], // 待复习卡片 id
    mastered_cards: [], // 已掌握卡片 id
    unlocked_fruits: [], // 已解锁果实 chapterId
    updated_at: 0, // 最近更新时间戳（云端合并用）
  }
}

export function get(key, def = null) {
  try {
    const v = uni.getStorageSync(key)
    return v === '' || v === undefined || v === null ? def : v
  } catch (e) {
    return def
  }
}

export function set(key, value) {
  try {
    uni.setStorageSync(key, value)
  } catch (e) {
    /* ignore */
  }
}

export function remove(key) {
  try {
    uni.removeStorageSync(key)
  } catch (e) {
    /* ignore */
  }
}

/** 读取进度并补齐默认字段。 */
export function getProgress() {
  const saved = get(KEYS.PROGRESS, null)
  if (!saved || typeof saved !== 'object') return defaultProgress()
  return { ...defaultProgress(), ...saved }
}

/** 写入进度并刷新 updated_at。 */
export function setProgress(p) {
  const next = { ...p, updated_at: Date.now() }
  set(KEYS.PROGRESS, next)
  return next
}

/** 清空本地进度（重置）。 */
export function clearProgress() {
  set(KEYS.PROGRESS, defaultProgress())
}

export default { KEYS, defaultProgress, get, set, remove, getProgress, setProgress, clearProgress }
