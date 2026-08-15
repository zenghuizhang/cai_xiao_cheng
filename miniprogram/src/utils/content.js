/**
 * 内容数据访问层 —— 加载 knowledge_base.json 并提供查询。
 * 字段口径注意：
 *   chapters[].id = "C1".."C4"，order_index = 1..4
 *   cards[].chapter = 数字 1..4（与 chapter.order_index 对应）
 *   quizzes / simulations / fruits 使用 chapter_id = "C1".."C4"
 */
import kb from '@/data/knowledge_base.json'

const meta = kb.meta || {}
const chapters = kb.chapters || []
const cards = kb.cards || []
const quizzes = kb.quizzes || []
const simulations = kb.simulations || []
const glossary = kb.glossary || []
const dailyChallenges = kb.daily_challenges || []
const books = kb.books || []
const riskQuiz = kb.risk_quiz || []
const fruits = kb.fruits || []
const booksNote = kb.books_note || ''

/* ---------- meta ---------- */
export function getMeta() {
  return meta
}
export function getDisclaimer() {
  return meta.disclaimer || '本App所有数据均为假设性教学案例，不构成任何投资建议。'
}

/* ---------- chapters ---------- */
export function getChapters() {
  return chapters
}
export function getChapter(id) {
  return chapters.find((c) => c.id === id) || null
}
/** 当前推荐章节：第一个未通关的。 */
export function getChapterByOrder(orderIndex) {
  return chapters.find((c) => c.order_index === orderIndex) || null
}

/* ---------- cards ---------- */
export function getAllCards() {
  return cards
}
export function getCard(id) {
  return cards.find((c) => c.id === id) || null
}
/** 按 chapterId("C1") 取卡片，内部用 order_index 映射数字 chapter 字段。 */
export function getCardsByChapter(chapterId) {
  const ch = getChapter(chapterId)
  const idx = ch ? ch.order_index : 0
  return cards
    .filter((c) => c.chapter === idx)
    .sort((a, b) => a.order_index - b.order_index)
}

/* ---------- quizzes ---------- */
export function getQuizzesByChapter(chapterId) {
  return quizzes
    .filter((q) => q.chapter_id === chapterId)
    .sort((a, b) => a.order_index - b.order_index)
}
export function getQuiz(id) {
  return quizzes.find((q) => q.id === id) || null
}

/* ---------- simulations ---------- */
export function getSimulations() {
  return simulations.sort((a, b) => a.order_index - b.order_index)
}
export function getSimulationsByChapter(chapterId) {
  return simulations
    .filter((s) => s.chapter_id === chapterId)
    .sort((a, b) => a.order_index - b.order_index)
}
export function getSimulation(id) {
  return simulations.find((s) => s.id === id) || null
}

/* ---------- glossary ---------- */
export function getGlossary() {
  return glossary
}
export function getGlossaryTerm(term) {
  return (
    glossary.find((g) => g.term === term) ||
    glossary.find((g) => (g.aliases || []).includes(term)) ||
    null
  )
}
/** 模糊搜索词条（用于悬浮查词）。 */
export function searchGlossary(keyword) {
  if (!keyword) return glossary
  const kw = keyword.trim().toLowerCase()
  return glossary.filter(
    (g) =>
      g.term.toLowerCase().includes(kw) ||
      (g.aliases || []).some((a) => a.toLowerCase().includes(kw))
  )
}

/* ---------- daily ---------- */
export function getDailyChallenges() {
  return dailyChallenges
}
/** 按日期取当日挑战（稳定，与日期绑定）。 */
export function getDailyByDate(dateStr) {
  if (!dailyChallenges.length) return null
  // 用日期字符串哈希到题目池，保证当天稳定
  let hash = 0
  for (let i = 0; i < dateStr.length; i++) {
    hash = (hash * 31 + dateStr.charCodeAt(i)) % 100000
  }
  const idx = hash % dailyChallenges.length
  return dailyChallenges[idx]
}

/* ---------- books ---------- */
export function getBooks() {
  return books
}
export function getBook(id) {
  return books.find((b) => b.id === id) || null
}
export function getBooksNote() {
  return booksNote
}

/* ---------- risk ---------- */
export function getRiskQuiz() {
  return riskQuiz
}

/* ---------- fruits（成长树果实） ---------- */
export function getFruits() {
  return fruits
}
export function getFruitByChapter(chapterId) {
  return fruits.find((f) => f.chapter_id === chapterId) || null
}

export default {
  getMeta,
  getDisclaimer,
  getChapters,
  getChapter,
  getChapterByOrder,
  getAllCards,
  getCard,
  getCardsByChapter,
  getQuizzesByChapter,
  getQuiz,
  getSimulations,
  getSimulationsByChapter,
  getSimulation,
  getGlossary,
  getGlossaryTerm,
  searchGlossary,
  getDailyChallenges,
  getDailyByDate,
  getBooks,
  getBook,
  getBooksNote,
  getRiskQuiz,
  getFruits,
  getFruitByChapter,
}
