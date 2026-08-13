/* ============================================================
   财小苗 · 本地存储与进度/成就
   全部存于 localStorage，无任何上报
   ============================================================ */
window.Cxm = window.Cxm || {};

Cxm.store = (function () {
  const K = {
    onboard: "cxm_onboarded",
    progress: "cxm_progress",   // {lessonId:"passed"}
    risk: "cxm_risk",           // 最近风险测评结果类型名
    achievements: "cxm_achievements", // [id...]
    streak: "cxm_streak",       // {last:"YYYY-MM-DD", days:n}
    firstOpen: "cxm_first_open"
  };

  function read(key, def) {
    try {
      const v = localStorage.getItem(key);
      return v == null ? def : JSON.parse(v);
    } catch (e) { return def; }
  }
  function write(key, val) {
    try { localStorage.setItem(key, JSON.stringify(val)); } catch (e) {}
  }

  /* ---------- 引导 ---------- */
  function isOnboarded() { return read(K.onboard, false) === true; }
  function setOnboarded() { write(K.onboard, true); }

  /* ---------- 首次打开 & 连续天数 ---------- */
  function pad2(n) { return (n < 10 ? "0" : "") + n; }
  function todayStr() {
    const d = new Date();
    return d.getFullYear() + "-" + pad2(d.getMonth() + 1) + "-" + pad2(d.getDate());
  }
  function dayDiff(a, b) {
    const da = new Date(a + "T00:00:00"), db = new Date(b + "T00:00:00");
    return Math.round((db - da) / 86400000);
  }
  function touchStreak() {
    const today = todayStr();
    let s = read(K.streak, null);
    if (!s) { s = { last: today, days: 1 }; write(K.firstOpen, today); }
    else if (s.last !== today) {
      const diff = dayDiff(s.last, today);
      if (diff === 1) s.days += 1;
      else if (diff > 1) s.days = 1;
      s.last = today;
    }
    write(K.streak, s);
    return s;
  }
  function getStreak() {
    const s = read(K.streak, null);
    if (!s) return 0;
    // 若上次打开是昨天或今天，连续仍在；否则归零显示
    const diff = dayDiff(s.last, todayStr());
    return diff <= 1 ? s.days : 0;
  }
  function getFirstOpen() { return read(K.firstOpen, null) || todayStr(); }

  /* ---------- 课程进度 ---------- */
  function getProgress() { return read(K.progress, {}); }
  function isPassed(lessonId) { return getProgress()[lessonId] === "passed"; }

  // 章节结构辅助
  function allLessons() {
    const list = [];
    Cxm.data.chapters.forEach(c => c.lessons.forEach(l => list.push(Object.assign({ chapter: c.id }, l))));
    return list;
  }
  function lessonById(id) {
    for (const c of Cxm.data.chapters) {
      const l = c.lessons.find(x => x.id === id);
      if (l) return { lesson: l, chapter: c };
    }
    return null;
  }
  function chapterProgress(ch) {
    const done = ch.lessons.filter(l => isPassed(l.id)).length;
    return { done, total: ch.lessons.length, pct: ch.lessons.length ? Math.round(done / ch.lessons.length * 100) : 0 };
  }
  function totalProgress() {
    const all = allLessons();
    const done = all.filter(l => isPassed(l.id)).length;
    return { done, total: all.length, pct: Math.round(done / all.length * 100) };
  }

  // 是否解锁：第一节默认解锁；其余需上一节通过
  function isLessonUnlocked(lessonId) {
    for (const c of Cxm.data.chapters) {
      const idx = c.lessons.findIndex(l => l.id === lessonId);
      if (idx >= 0) {
        if (idx === 0) {
          // 第一章第一节直接解锁；其他章需上一章全部完成
          if (c.id === 1) return true;
          const prev = Cxm.data.chapters.find(x => x.id === c.id - 1);
          return prev ? prev.lessons.every(l => isPassed(l.id)) : false;
        }
        return isPassed(c.lessons[idx - 1].id);
      }
    }
    return false;
  }
  function isChapterUnlocked(ch) {
    if (ch.id === 1) return true;
    const prev = Cxm.data.chapters.find(x => x.id === ch.id - 1);
    return prev ? prev.lessons.every(l => isPassed(l.id)) : false;
  }

  function passLesson(lessonId) {
    const p = getProgress();
    const wasNew = p[lessonId] !== "passed";
    p[lessonId] = "passed";
    write(K.progress, p);
    if (wasNew) touchStreak();
    return wasNew;
  }

  /* ---------- 风险测评 ---------- */
  function getRiskResult() { return read(K.risk, null); }
  function setRiskResult(typeName) { write(K.risk, typeName); touchStreak(); }

  /* ---------- 成就 ---------- */
  const ACH = [
    { id: "sprout", name: "破土而出", emoji: "🌱", desc: "完成第 1 节课" },
    { id: "chapter1", name: "初窥门径", emoji: "📚", desc: "完成第 1 章" },
    { id: "compound", name: "复利信徒", emoji: "💧", desc: "使用过复利计算器" },
    { id: "shield", name: "防骗卫士", emoji: "🛡️", desc: "完成《避开镰刀》章" },
    { id: "risk", name: "知己知彼", emoji: "🎯", desc: "完成风险承受力测评" },
    { id: "tree", name: "财商小树", emoji: "🌳", desc: "学完全部 7 章" }
  ];
  function getAchievements() { return read(K.achievements, []); }
  function unlock(id) {
    const got = getAchievements();
    if (got.indexOf(id) >= 0) return false;
    got.push(id);
    write(K.achievements, got);
    return ACH.find(a => a.id === id) || true;
  }
  function useTool(name) {
    if (name === "compound") unlock("compound");
  }

  // 根据当前进度检查/解锁成就，返回新解锁的列表
  function evaluateAchievements() {
    const newly = [];
    const tp = totalProgress();
    let a;
    if (tp.done >= 1 && (a = unlock("sprout")) && a !== false) newly.push(a);
    const ch1 = Cxm.data.chapters[0];
    if (ch1.lessons.every(l => isPassed(l.id)) && (a = unlock("chapter1")) && a !== false) newly.push(a);
    const ch6 = Cxm.data.chapters.find(c => c.id === 6);
    if (ch6.lessons.every(l => isPassed(l.id)) && (a = unlock("shield")) && a !== false) newly.push(a);
    if (tp.done === tp.total && (a = unlock("tree")) && a !== false) newly.push(a);
    if (getRiskResult() && (a = unlock("risk")) && a !== false) newly.push(a);
    return newly.filter(x => x && x.id);
  }

  /* ---------- 重置 ---------- */
  function resetAll() {
    Object.values(K).forEach(k => localStorage.removeItem(k));
  }

  return {
    K, isOnboarded, setOnboarded,
    touchStreak, getStreak, getFirstOpen,
    getProgress, isPassed, passLesson, allLessons, lessonById,
    chapterProgress, totalProgress, isLessonUnlocked, isChapterUnlocked,
    getRiskResult, setRiskResult,
    ACH, getAchievements, unlock, useTool, evaluateAchievements,
    resetAll
  };
})();
