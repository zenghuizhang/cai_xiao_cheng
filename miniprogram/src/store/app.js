/**
 * 应用状态 Store —— 移植自 Flutter AppState + DatabaseHelper 逻辑。
 * 进度本地优先（storage），登录后由 user store 监听 'progress-changed' 云端同步。
 */
import { defineStore } from 'pinia'
import { getProgress, setProgress, defaultProgress } from '@/utils/storage'
import {
  getChapters,
  getAllCards,
  getQuizzesByChapter,
} from '@/utils/content'

/** 段位标题（等级→标题）。通关 C1 后升 2 级「白银学徒」，依此类推。 */
export const RANK_TITLES = {
  1: '青铜小白',
  2: '白银学徒',
  3: '黄金规划师',
  4: '铂金守心人',
}

/** yyyy-mm-dd。 */
function ymd(d) {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

export const useAppStore = defineStore('app', {
  state: () => ({
    progress: defaultProgress(),
    chapters: [],
    totalCards: 0,
    loaded: false,
  }),

  getters: {
    totalPoints: (s) => s.progress.total_points,
    currentLevel: (s) => s.progress.current_level,
    rankTitle: (s) => s.progress.rank_title,
    cardsReadCount: (s) => s.progress.cards_read.length,
    chaptersPassedCount: (s) => s.progress.passed_chapters.length,
    streak: (s) => s.progress.daily_streak,
    crashUsed: (s) => s.progress.crash_used,
    onboardingDone: (s) => s.progress.onboarding_done,
    riskProfile: (s) => s.progress.risk_profile,
    reviewQueue: (s) => s.progress.review_queue,
    reviewCount: (s) => s.progress.review_queue.length,
    masteredCount: (s) => s.progress.mastered_cards.length,
    passedChapters: (s) => s.progress.passed_chapters,
    unlockedFruits: (s) => s.progress.unlocked_fruits,
    /** 虚拟资产：1 积分 = 10 元「认知本金」（纯虚拟，非真实货币）。 */
    virtualAssets: (s) => 10000 + s.progress.total_points * 10,
    /** 当前推荐章节：第一个未通关的；全部通关则返回最后一章。 */
    currentChapter: (s) => {
      for (const c of s.chapters) {
        if (!s.progress.passed_chapters.includes(c.id)) return c
      }
      return s.chapters.length ? s.chapters[s.chapters.length - 1] : null
    },
  },

  actions: {
    /** 从本地存储恢复进度 + 载入内容索引。 */
    init() {
      this.progress = getProgress()
      this.chapters = getChapters()
      this.totalCards = getAllCards().length
      this.loaded = true
    },

    /** 章节是否解锁：C1 始终解锁；其余需上一章通关。 */
    isChapterUnlocked(chapter) {
      if (!chapter) return false
      if (chapter.unlock_type === 'none' || chapter.order_index === 1) return true
      if (!chapter.unlock_ref) return true
      return this.progress.passed_chapters.includes(chapter.unlock_ref)
    },

    /** 该章节已读卡片数 / 总数。 */
    chapterReadStat(chapterId) {
      const idx = (this.chapters.find((c) => c.id === chapterId) || {}).order_index
      const total = getAllCards().filter((c) => c.chapter === idx).length
      // 已读 = cards_read 中属于该章的
      const read = this.progress.cards_read.filter((id) => {
        const card = getAllCards().find((c) => c.id === id)
        return card && card.chapter === idx
      }).length
      return { read, total }
    },

    /** 持久化并广播变更（user store 监听后 debounce 云端同步）。 */
    _persist() {
      this.progress = setProgress(this.progress)
      try {
        uni.$emit('progress-changed', this.progress)
      } catch (e) {
        /* ignore */
      }
    },

    /**
     * 记录一次卡片滑动。
     * status: 'got'(懂了) | 'review'(没懂，入复习队列)
     * 懂了：每卡只加一次积分；同步移出复习队列。
     */
    recordCard(cardId, status, points) {
      const p = this.progress
      if (status === 'got') {
        if (!p.cards_read.includes(cardId)) {
          p.cards_read.push(cardId)
          p.total_points += points || 0
        }
        // 懂了就不再需要复习
        p.review_queue = p.review_queue.filter((id) => id !== cardId)
      } else {
        // 没懂 → 入复习队列；若曾掌握则取消掌握
        if (!p.review_queue.includes(cardId)) p.review_queue.push(cardId)
        p.mastered_cards = p.mastered_cards.filter((id) => id !== cardId)
      }
      this._persist()
    },

    /** 该卡是否已「懂了」。 */
    isCardRead(cardId) {
      return this.progress.cards_read.includes(cardId)
    },

    /**
     * 记录一次闯关测验。通过线 ≥80%。
     * 首次通过该章：加该章全部 quiz 积分之和 + 解锁果实 + 升段位。
     * 返回 { passed, earned }。
     */
    recordQuiz(chapterId, correct, total) {
      const p = this.progress
      const rate = total === 0 ? 0 : correct / total
      const passed = rate >= 0.8
      const firstPass = passed && !p.passed_chapters.includes(chapterId)
      let earned = 0
      if (firstPass) {
        const qs = getQuizzesByChapter(chapterId)
        earned = qs.reduce((a, q) => a + (q.points || 0), 0)
        p.total_points += earned
        p.passed_chapters.push(chapterId)
        if (!p.unlocked_fruits.includes(chapterId)) {
          p.unlocked_fruits.push(chapterId)
        }
        // 升段位：通关 order → level = order+1，封顶 4
        const order = parseInt(chapterId.substring(1), 10)
        const newLevel = Math.min(Math.max(order + 1, 1), 4)
        p.current_level = newLevel
        p.rank_title = RANK_TITLES[newLevel]
      }
      p.quiz_records[chapterId] = { correct, total, passed, earned, ts: Date.now() }
      this._persist()
      return { passed, earned }
    },

    /** 记录一次历史模拟选择。每个模拟首次作答 +15。返回获得积分。 */
    recordSim(simId, chosenKey, pnlPct) {
      const p = this.progress
      const first = !p.sim_records[simId]
      const earned = first ? 15 : 0
      p.sim_records[simId] = { key: chosenKey, pnl: pnlPct, ts: Date.now(), earned }
      if (first) p.total_points += earned
      this._persist()
      return earned
    },

    /**
     * 每日挑战：correct*10 + 全对额外 20。
     * 同日重做覆盖当日记录（积分差额调整）。连击以 last_daily_date 锚点。
     * 返回 { earned, streak }。
     */
    recordDaily(correct, total) {
      const p = this.progress
      const now = new Date()
      const today = ymd(now)
      const earned = correct * 10 + (correct === total ? 20 : 0)
      const prev = p.daily_records[today]
      const prevEarned = prev ? prev.earned || 0 : 0
      p.daily_records[today] = { correct, total, earned, ts: Date.now() }
      p.total_points = p.total_points - prevEarned + earned

      const yesterday = ymd(new Date(now.getTime() - 86400000))
      if (p.last_daily_date === yesterday) {
        p.daily_streak += 1
      } else if (p.last_daily_date === today) {
        // 今日已计过，连击不变
      } else {
        p.daily_streak = 1
      }
      p.last_daily_date = today
      this._persist()
      return { earned, streak: p.daily_streak }
    },

    /** 今日是否已完成每日挑战。 */
    isDailyDoneToday() {
      const today = ymd(new Date())
      const r = this.progress.daily_records[today]
      return !!r
    },

    /** 暴跌演练：标记已使用，返回是否首次。 */
    markCrash() {
      const first = !this.progress.crash_used
      this.progress.crash_used = true
      this._persist()
      return first
    },

    /** 完成引导。 */
    finishOnboarding() {
      this.progress.onboarding_done = true
      this._persist()
    },

    /** 保存风险测评画像（可重测覆盖）。 */
    saveRiskProfile(type) {
      this.progress.risk_profile = type
      this._persist()
    },

    /**
     * 复习反馈：mastered=true 移出队列 + 掌握 +5；false 留队。
     */
    recordReview(cardId, mastered) {
      const p = this.progress
      if (mastered) {
        p.review_queue = p.review_queue.filter((id) => id !== cardId)
        if (!p.mastered_cards.includes(cardId)) {
          p.mastered_cards.push(cardId)
          p.total_points += 5
        }
      }
      this._persist()
    },

    /** 风险画像展示映射。 */
    riskProfileMeta(type) {
      switch (type) {
        case 'conservative':
          return { emoji: '🛡️', title: '保守型', desc: '保本优先，波动要小' }
        case 'aggressive':
          return { emoji: '🚀', title: '进取型', desc: '追求高收益，扛得住大波动' }
        default:
          return { emoji: '⚖️', title: '稳健型', desc: '平衡增长，跑赢通胀' }
      }
    },

    /** 风险画像对应建议股债配置（呼应 100-年龄法则，教学参考）。 */
    riskAllocation(type) {
      switch (type) {
        case 'conservative':
          return '股 20% / 债 80%'
        case 'aggressive':
          return '股 60% / 债 40%'
        default:
          return '股 40% / 债 60%'
      }
    },

    /** 重置进度（保留引导完成 + 风险画像，与 Flutter 行为一致）。 */
    reset() {
      const keep = {
        onboarding_done: this.progress.onboarding_done,
        risk_profile: this.progress.risk_profile,
      }
      this.progress = { ...defaultProgress(), ...keep }
      this._persist()
    },

    /** 用合并后的进度覆盖本地（云端同步用）。 */
    applyMergedProgress(merged) {
      this.progress = { ...defaultProgress(), ...merged }
      this.loaded = true
    },
  },
})
