/* ============================================================
   财小苗 · 应用主逻辑
   路由 / 组件 / 图表 / 全部页面
   ============================================================ */
(function () {
  "use strict";
  const D = Cxm.data, S = Cxm.store;
  const $ = (s, r) => (r || document).querySelector(s);
  const $$ = (s, r) => Array.prototype.slice.call((r || document).querySelectorAll(s));

  /* ---------------- 工具函数 ---------------- */
  function esc(s) {
    return String(s).replace(/[&<>"']/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]));
  }
  function fmt(n) {
    return Math.round(n).toLocaleString("zh-CN");
  }
  function pct(n) { return (Math.round(n * 10) / 10) + "%"; }

  // 解析 **加粗** 与 [[术语]]
  function rich(text) {
    if (text == null) return "";
    let html = esc(text);
    html = html.replace(/\*\*(.+?)\*\*/g, "<strong>$1</strong>");
    html = html.replace(/\[\[(.+?)\]\]/g, (m, name) => {
      const t = D.terms.find(x => x.name === name || (x.aliases || []).indexOf(name) >= 0);
      if (!t) return esc(name);
      return `<span class="term" data-term="${esc(t.name)}">${esc(name)}</span>`;
    });
    return html;
  }

  /* ---------------- Toast / 弹层 / 确认框 ---------------- */
  let toastTimer = null;
  Cxm.toast = function (msg) {
    const t = $("#toast");
    t.textContent = msg;
    t.classList.remove("hidden");
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => t.classList.add("hidden"), 2200);
  };

  Cxm.confirm = function (opt) {
    const mask = document.createElement("div");
    mask.className = "modal-mask";
    mask.innerHTML = `
      <div class="modal">
        <h3>${esc(opt.title || "确认")}</h3>
        <p>${esc(opt.content || "")}</p>
        <div class="btn-row">
          <button class="btn btn-line" data-act="cancel">${esc(opt.cancelText || "取消")}</button>
          <button class="btn ${opt.danger ? "btn-primary" : "btn-accent"}" data-act="ok" ${opt.danger ? 'style="background:var(--danger);box-shadow:0 6px 14px rgba(229,84,75,.3)"' : ""}>${esc(opt.okText || "确定")}</button>
        </div>
      </div>`;
    document.body.appendChild(mask);
    function close(v) {
      mask.remove();
      if (v && opt.onOk) opt.onOk();
      if (!v && opt.onCancel) opt.onCancel();
    }
    mask.addEventListener("click", e => {
      if (e.target === mask) close(false);
      const act = e.target.closest("[data-act]");
      if (act) close(act.dataset.act === "ok");
    });
  };

  function openTerm(name) {
    const t = D.terms.find(x => x.name === name);
    if (!t) return;
    const mask = document.createElement("div");
    mask.className = "sheet-mask";
    mask.innerHTML = `
      <div class="sheet">
        <div class="sheet-handle"></div>
        <h3><span class="s-term">${esc(t.name)}</span></h3>
        <div class="muted small">${esc(t.cat)}${t.aliases && t.aliases.length ? " · 亦称：" + t.aliases.map(esc).join("、") : ""}</div>
        <div class="s-body"><strong style="color:var(--brand-dark)">${esc(t.short)}</strong><br><br>${esc(t.body)}</div>
        ${t.eg ? `<div class="s-eg"><strong>举个栗子：</strong>${esc(t.eg)}</div>` : ""}
        <button class="btn btn-primary s-close">知道了</button>
      </div>`;
    document.body.appendChild(mask);
    function close() { mask.remove(); }
    mask.addEventListener("click", e => {
      if (e.target === mask || e.target.closest(".s-close")) close();
    });
  }
  Cxm.openTerm = openTerm;

  /* ---------------- 小苗吉祥物 SVG ---------------- */
  function sprout(mood) {
    mood = mood || "happy";
    let face = "";
    if (mood === "warn") {
      face = `
        <circle cx="40" cy="78" r="4.2" fill="#fff"/><circle cx="60" cy="78" r="4.2" fill="#fff"/>
        <circle cx="40.5" cy="79" r="2" fill="#1B3A2E"/><circle cx="60.5" cy="79" r="2" fill="#1B3A2E"/>
        <ellipse cx="50" cy="91" rx="3" ry="3.6" fill="#1B3A2E"/>
        <path d="M76 62 q-5 5 -8 0 q3 -3 8 0z" fill="#6FB8E8"/>`;
    } else if (mood === "sad") {
      face = `
        <path d="M36 76 l8 6 M44 76 l-8 6" stroke="#1B3A2E" stroke-width="2.4" stroke-linecap="round"/>
        <path d="M64 76 l-8 6 M56 76 l8 6" stroke="#1B3A2E" stroke-width="2.4" stroke-linecap="round"/>
        <path d="M42 92 Q50 84 58 92" stroke="#1B3A2E" stroke-width="2.4" fill="none" stroke-linecap="round"/>`;
    } else if (mood === "celebrate") {
      face = `
        <path d="M36 78 q4 5 9 0" stroke="#1B3A2E" stroke-width="2.6" fill="none" stroke-linecap="round"/>
        <path d="M55 78 q4 5 9 0" stroke="#1B3A2E" stroke-width="2.6" fill="none" stroke-linecap="round"/>
        <path d="M42 88 Q50 97 58 88" stroke="#1B3A2E" stroke-width="2.6" fill="none" stroke-linecap="round"/>
        <g fill="#F5A623"><path d="M20 48 l2 5 5 2 -5 2 -2 5 -2-5 -5-2 5-2z"/>
        <path d="M82 38 l1.6 4 4 1.6 -4 1.6 -1.6 4 -1.6-4 -4-1.6 4-1.6z"/>
        <path d="M86 70 l1.4 3.4 3.4 1.4 -3.4 1.4 -1.4 3.4 -1.4-3.4 -3.4-1.4 3.4-1.4z"/></g>`;
    } else { // happy
      face = `
        <path d="M36 78 q4 5 9 0" stroke="#1B3A2E" stroke-width="2.6" fill="none" stroke-linecap="round"/>
        <path d="M55 78 q4 5 9 0" stroke="#1B3A2E" stroke-width="2.6" fill="none" stroke-linecap="round"/>
        <path d="M42 87 Q50 96 58 87" stroke="#1B3A2E" stroke-width="2.6" fill="none" stroke-linecap="round"/>`;
    }
    return `
    <svg viewBox="0 0 100 116" class="sprout-svg" role="img" aria-label="小苗">
      <path d="M50 50 C40 47 30 38 33 27 C44 26 50 36 50 50 Z" fill="#C7F0A0" stroke="#9FD978" stroke-width="1.5"/>
      <path d="M50 46 C60 43 70 34 67 23 C56 22 50 32 50 46 Z" fill="#D8F6B2" stroke="#9FD978" stroke-width="1.5"/>
      <path d="M50 52 C49 42 51 36 50 28" stroke="#1F7A56" stroke-width="3" fill="none" stroke-linecap="round"/>
      <ellipse cx="50" cy="83" rx="33" ry="32" fill="#2FA877"/>
      <ellipse cx="38" cy="72" rx="14" ry="9" fill="#fff" opacity=".18"/>
      <circle cx="31" cy="90" r="5" fill="#F5A623" opacity=".55"/>
      <circle cx="69" cy="90" r="5" fill="#F5A623" opacity=".55"/>
      ${face}
    </svg>`;
  }

  /* ---------------- 进度环 ---------------- */
  function ring(pctv, size) {
    size = size || 96;
    const r = 38, c = 2 * Math.PI * r;
    const off = c * (1 - Math.max(0, Math.min(100, pctv)) / 100);
    return `
    <svg width="${size}" height="${size}" viewBox="0 0 100 100" class="score-ring">
      <circle cx="50" cy="50" r="${r}" fill="none" stroke="var(--line)" stroke-width="9"/>
      <circle cx="50" cy="50" r="${r}" fill="none" stroke="url(#ringGrad)" stroke-width="9"
        stroke-linecap="round" stroke-dasharray="${c.toFixed(1)}" stroke-dashoffset="${off.toFixed(1)}"
        transform="rotate(-90 50 50)" style="transition:stroke-dashoffset .8s ease">
      </circle>
      <defs><linearGradient id="ringGrad" x1="0" y1="0" x2="1" y2="1">
        <stop offset="0" stop-color="#34B889"/><stop offset="1" stop-color="#1F7A56"/>
      </linearGradient></defs>
      <text x="50" y="56" text-anchor="middle" font-size="22" font-weight="700" fill="#1F7A56">${pctv}%</text>
    </svg>`;
  }

  /* ---------------- SVG 折线图 ---------------- */
  function niceDomain(min, max) {
    if (min === max) { min = 0; max = min ? max * 1.2 : 1; }
    if (min > 0) min = 0; // 收益图从 0 开始更直观
    const range = max - min;
    const raw = range / 4;
    const mag = Math.pow(10, Math.floor(Math.log10(raw)));
    const n = raw / mag;
    const step = (n < 1 ? 1 : n < 2 ? 2 : n < 5 ? 5 : 10) * mag;
    return { min: Math.floor(min / step) * step, max: Math.ceil(max / step) * step, step };
  }
  function lineChart(cfg) {
    const w = cfg.w || 320, h = cfg.h || 200;
    const pad = { l: 46, r: 12, t: 14, b: 22 };
    const iw = w - pad.l - pad.r, ih = h - pad.t - pad.b;
    const all = cfg.series.reduce((a, s) => a.concat(s.data), []);
    let mn = cfg.minY != null ? cfg.minY : Math.min.apply(null, all);
    let mx = cfg.maxY != null ? cfg.maxY : Math.max.apply(null, all);
    const dom = niceDomain(mn, mx);
    const N = cfg.series[0].data.length;
    const X = i => pad.l + (N <= 1 ? iw / 2 : i * iw / (N - 1));
    const Y = v => pad.t + ih - (v - dom.min) / (dom.max - dom.min) * ih;
    let svg = `<svg viewBox="0 0 ${w} ${h}" width="100%" preserveAspectRatio="xMidYMid meet">`;
    // 网格 + Y 标签
    for (let v = dom.min; v <= dom.max + 0.001; v += dom.step) {
      const y = Y(v);
      svg += `<line x1="${pad.l}" y1="${y}" x2="${w - pad.r}" y2="${y}" stroke="var(--line)" stroke-width="1"/>`;
      svg += `<text x="${pad.l - 6}" y="${y + 4}" text-anchor="end" font-size="10" fill="var(--ink-3)">${cfg.yFmt ? cfg.yFmt(v) : Math.round(v)}</text>`;
    }
    // X 标签（首/中/末）
    const n = cfg.series[0].data.length;
    [0, Math.floor((n - 1) / 2), n - 1].forEach(i => {
      if (i < 0) return;
      svg += `<text x="${X(i)}" y="${h - 6}" text-anchor="middle" font-size="10" fill="var(--ink-3)">${cfg.xLabel ? cfg.xLabel(i) : i}</text>`;
    });
    cfg.series.forEach(s => {
      if (s.area && n > 1) {
        let p = `M${X(0)},${Y(s.data[0])}`;
        s.data.forEach((v, i) => { if (i > 0) p += ` L${X(i)},${Y(v)}`; });
        p += ` L${X(n - 1)},${pad.t + ih} L${X(0)},${pad.t + ih} Z`;
        svg += `<path d="${p}" fill="${s.color}" opacity="0.13"/>`;
      }
      if (n > 1) {
        let p = `M${X(0)},${Y(s.data[0])}`;
        s.data.forEach((v, i) => { if (i > 0) p += ` L${X(i)},${Y(v)}`; });
        svg += `<path d="${p}" fill="none" stroke="${s.color}" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round"/>`;
      }
      s.data.forEach((v, i) => {
        if (i === n - 1) svg += `<circle cx="${X(i)}" cy="${Y(v)}" r="3.5" fill="${s.color}"/>`;
      });
    });
    svg += `</svg>`;
    return svg;
  }

  /* ---------------- 页面渲染 ---------------- */
  const view = $("#view");
  let tabTimer = null;
  function setTab(which) {
    $$("#tabbar .tab").forEach(t => t.classList.toggle("active", t.dataset.route === "#/" + which || (which === "" && t.dataset.route === "#/")));
  }
  function showTabbar(show) { $("#tabbar").style.display = show ? "flex" : "none"; }

  function go(hash) { location.hash = hash; }

  function render(innerHtml, opts) {
    opts = opts || {};
    const cls = "view " + (opts.cls || "") + " page-enter";
    view.className = cls.trim();
    view.innerHTML = innerHtml;
    window.scrollTo(0, 0);
    showTabbar(!!opts.tabbar);
    if (opts.tab) setTab(opts.tab);
    if (opts.mounted) opts.mounted();
  }

  function topbar(backHash, title, sub) {
    return `
    <div class="topbar">
      <button class="back" data-href="${esc(backHash)}" aria-label="返回">
        <svg width="20" height="20" viewBox="0 0 24 24"><path d="M15 5l-7 7 7 7" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
      </button>
      <div class="ttl">${esc(title)}</div>
      ${sub ? `<div class="sub">${esc(sub)}</div>` : ""}
    </div>`;
  }

  function greeting() {
    const h = new Date().getHours();
    if (h < 6) return "夜深了，早点休息";
    if (h < 11) return "早上好";
    if (h < 14) return "中午好";
    if (h < 18) return "下午好";
    return "晚上好";
  }

  /* ============ 引导页 ============ */
  function vOnboarding() {
    showTabbar(false);
    const slides = [
      { emo: "sprout", title: "我不荐股", text: "这里没有股票代码、没有带单老师，只有从零开始的投资认知。" },
      { emo: "shield", title: "我不碰你的钱", text: "不交易、不开户、不登录、不支付。学习的事归学习，钱永远在你自己手里。" },
      { emo: "offline", title: "随时离线，不收集数据", text: "所有内容都在手机里，飞行模式也能用。我们不知道你是谁，也不需要知道。" }
    ];
    function slideArt(kind) {
      if (kind === "sprout") return `<div class="onb-emo">${sprout("happy")}</div>`;
      if (kind === "shield") return `<div class="onb-emo"><svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="42" fill="#E4F4EC"/><path d="M50 22 L72 31 V52 C72 68 62 78 50 82 C38 78 28 68 28 52 V31 Z" fill="#2FA877"/><path d="M40 50 l7 7 14 -15" fill="none" stroke="#fff" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"/></svg></div>`;
      return `<div class="onb-emo"><svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="42" fill="#E6F0FF"/><path d="M30 50 a20 20 0 0 1 36 -12" fill="none" stroke="#3A86FF" stroke-width="4" stroke-linecap="round"/><path d="M70 50 a20 20 0 0 1 -36 12" fill="none" stroke="#3A86FF" stroke-width="4" stroke-linecap="round"/><circle cx="34" cy="46" r="4" fill="#3A86FF"/><circle cx="66" cy="54" r="4" fill="#3A86FF"/></svg></div>`;
    }
    const dots = slides.map((_, i) => `<i data-i="${i}" class="${i === 0 ? "active" : ""}"></i>`).join("");
    render(`
      <div class="onb">
        <div class="onb-slides">
          ${slides.map((s, i) => `
            <div class="onb-slide ${i === 0 ? "active" : ""}" data-i="${i}">
              ${slideArt(s.emo)}
              <h2>${esc(s.title)}</h2>
              <p>${esc(s.text)}</p>
            </div>`).join("")}
        </div>
        <div class="onb-dots">${dots}</div>
        <div class="onb-actions">
          <button class="skip" id="onbSkip">跳过</button>
          <button class="btn btn-primary" id="onbNext" style="flex:1">下一步</button>
        </div>
      </div>`, { cls: "no-tab", mounted() {
        let cur = 0;
        function show(i) {
          cur = i;
          $$(".onb-slide").forEach(el => el.classList.toggle("active", +el.dataset.i === i));
          $$(".onb-dots i").forEach(el => el.classList.toggle("active", +el.dataset.i === i));
          $("#onbNext").textContent = i === slides.length - 1 ? "开始学习 🌱" : "下一步";
        }
        $("#onbNext").addEventListener("click", () => {
          if (cur < slides.length - 1) show(cur + 1);
          else { S.setOnboarded(); S.touchStreak(); location.replace("#/"); }
        });
        $("#onbSkip").addEventListener("click", () => { S.setOnboarded(); location.replace("#/"); });
        $$(".onb-dots i").forEach(d => d.addEventListener("click", () => show(+d.dataset.i)));
      }});
  }

  /* ============ 学习首页 ============ */
  const THEMES = {
    green: ["#2FA877", "#1F7A56"], orange: ["#F5A623", "#E0900B"],
    blue: ["#3A86FF", "#2B63C4"], teal: ["#1FB8A6", "#128779"],
    purple: ["#8E7CF0", "#6A57D6"], red: ["#F0706A", "#C83E36"]
  };
  function vLearn() {
    S.touchStreak();
    const tp = S.totalProgress();
    const nodes = D.chapters.map(c => {
      const cp = S.chapterProgress(c);
      const unlocked = S.isChapterUnlocked(c);
      const state = !unlocked ? "locked" : (cp.pct === 100 ? "done" : (tp.done > 0 || c.id === 1 ? cp.pct > 0 ? "current" : "" : c.id === 1 ? "current" : ""));
      const cur = (state === "current" || (c.id === 1 && tp.done === 0)) ? "current" : state;
      const dotLabel = cp.pct === 100 ? "✓" : c.id;
      return `
        <div class="tl-node ${cur}">
          <div class="dot">${dotLabel}</div>
          <div class="tl-card card-tap" data-chapter="${c.id}" ${!unlocked ? "" : ""}>
            <h3>${esc(c.emoji)} ${esc(c.title)}
              ${!unlocked ? '<span class="lock-ic">🔒</span>' : ""}
            </h3>
            <div class="tl-meta">
              <span>${c.lessons.length} 节</span>
              <span>约 ${c.lessons.reduce((a, l) => a + l.minutes, 0)} 分钟</span>
            </div>
            <div class="tl-desc">${esc(c.summary)}</div>
            <div class="mini-bar"><i style="width:${cp.pct}%"></i></div>
          </div>
        </div>`;
    }).join("");

    render(`
      <div class="greet">
        <div class="sprout-sm">${sprout("happy")}</div>
        <div>
          <h2>${greeting()}，未来的理财高手</h2>
          <p>先搞懂再动手，我们不急 🌱</p>
        </div>
      </div>
      <div class="progress-card">
        <div class="pc-top"><span class="lbl">学习路径总进度</span><span class="pct tnum">${tp.pct}%</span></div>
        <div class="progress-bar"><i style="width:${tp.pct}%"></i></div>
        <div class="pc-top" style="margin-top:8px;margin-bottom:0"><span class="lbl">已完成 ${tp.done} / ${tp.total} 节</span><span class="lbl">${D.chapters.filter(c => c.lessons.every(l => S.isPassed(l.id))).length} / 7 章</span></div>
      </div>
      <div class="section-title">学习路径</div>
      <div class="timeline">${nodes}</div>
      <div class="card flat center" style="margin-top:14px">
        <div style="font-size:13px;color:var(--ink-2);line-height:1.7">🧭 跟着顺序学下来，每节只有 3 分钟左右。<br>通过小节测验即可解锁下一节，学不完也没关系，进度自动保存。</div>
      </div>`,
      { tabbar: true, tab: "" });
  }

  /* ============ 章节详情 ============ */
  function vChapter(id) {
    const c = D.chapters.find(x => x.id === +id);
    if (!c) return go("#/");
    if (!S.isChapterUnlocked(c)) { Cxm.toast("先完成上一章哦"); return go("#/"); }
    const cp = S.chapterProgress(c);
    const th = THEMES[c.theme] || THEMES.green;
    const items = c.lessons.map((l, i) => {
      const passed = S.isPassed(l.id);
      const unlocked = S.isLessonUnlocked(l.id);
      return `
        <div class="lesson-item ${passed ? "done" : ""} ${!unlocked ? "locked" : ""}" ${unlocked ? `data-lesson="${l.id}"` : ""}>
          <div class="li-no">${passed ? "✓" : i + 1}</div>
          <div class="li-body">
            <div class="li-title">${esc(l.title)} ${passed ? '<span style="color:var(--brand);font-size:13px">已完成</span>' : ""}</div>
            <div class="li-meta">⏱ ${l.minutes} 分钟 · 难度 ${"★".repeat(l.level)}${"☆".repeat(3 - l.level)} · ${l.quiz.length} 题</div>
          </div>
          <div class="li-go">${unlocked ? "›" : "🔒"}</div>
        </div>`;
    }).join("");
    render(`
      ${topbar("#/", "第 " + c.id + " 章", cp.pct + "%")}
      <div class="page-body">
        <div class="chap-hero" style="background:linear-gradient(135deg,${th[0]},${th[1]})">
          <div class="ch-emoji">${c.emoji}</div>
          <h2>${esc(c.title)}</h2>
          <p>${esc(c.summary)}</p>
          <div class="chap-prog"><span>本章进度</span><span>${cp.done} / ${cp.total} 节</span></div>
          <div class="progress-bar" style="margin-top:6px;background:rgba(255,255,255,.25)"><i style="width:${cp.pct}%"></i></div>
        </div>
        <div class="card">${items}</div>
      </div>`, { cls: "page", mounted() {
        $$(".lesson-item[data-lesson]").forEach(el =>
          el.addEventListener("click", () => go("#/lesson/" + el.dataset.lesson)));
      } });
  }

  /* ============ 课程正文 + 测验 ============ */
  function renderBlocks(lesson) {
    return lesson.blocks.map(b => {
      if (b.t === "hero") return `<div class="lb-block"><div class="lb-hero">${rich(b.text)}</div></div>`;
      if (b.t === "p") return `<div class="lb-block"><p>${rich(b.text)}</p></div>`;
      if (b.t === "point") return `<div class="lb-block"><div class="lb-point">${rich(b.text)}</div></div>`;
      if (b.t === "warn") return `<div class="lb-block"><div class="lb-warn">${rich(b.text)}</div></div>`;
      if (b.t === "list") return `<div class="lb-block"><ul class="lb-list">${b.items.map(i => `<li>${rich(i)}</li>`).join("")}</ul></div>`;
      if (b.t === "fig") return `<div class="lb-block"><figure class="lb-fig"><div class="fig-emo">${esc(b.emoji)}</div><figcaption>${esc(b.caption)}</figcaption></figure></div>`;
      return "";
    }).join("");
  }

  // 成就解锁横幅（排队）
  const unlockQueue = [];
  function flushUnlocks() {
    if (unlockQueue.length === 0 || $("#unlockBanner")) return;
    const a = unlockQueue.shift();
    const bar = document.createElement("div");
    bar.id = "unlockBanner";
    bar.className = "unlock-banner";
    bar.innerHTML = `<div class="ub-ico">${a.emoji}</div><h4>解锁徽章：${esc(a.name)}</h4><p>${esc(a.desc)}</p>`;
    document.body.appendChild(bar);
    setTimeout(() => { bar.remove(); setTimeout(flushUnlocks, 250); }, 2400);
  }
  function checkAchievements() {
    const newly = S.evaluateAchievements();
    if (newly.length) {
      unlockQueue.push.apply(unlockQueue, newly);
      flushUnlocks();
    }
  }

  function vLesson(id) {
    const found = S.lessonById(id);
    if (!found) return go("#/");
    const { lesson: l, chapter: c } = found;
    if (!S.isLessonUnlocked(l.id)) { Cxm.toast("先完成上一节吧"); return go("#/chapter/" + c.id); }
    const idx = c.lessons.findIndex(x => x.id === l.id);
    const passed = S.isPassed(l.id);
    const th = THEMES[c.theme] || THEMES.green;

    render(`
      <div class="lesson-cover" style="background:linear-gradient(135deg,${th[0]},${th[1]})">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:10px">
          <button class="back" data-href="#/chapter/${c.id}" style="background:rgba(255,255,255,.2);color:#fff;backdrop-filter:blur(4px)">
            <svg width="20" height="20" viewBox="0 0 24 24"><path d="M15 5l-7 7 7 7" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"/></svg>
          </button>
          <span class="lc-kicker">第 ${c.id} 章 · 第 ${idx + 1} 节 / 共 ${c.lessons.length} 节</span>
        </div>
        <h1>${esc(l.title)}</h1>
        <div class="lc-meta"><span>⏱ ${l.minutes} 分钟</span><span>难度 ${"★".repeat(l.level)}${"☆".repeat(3 - l.level)}</span><span>📝 ${l.quiz.length} 道小题</span></div>
      </div>
      <div class="lesson-body">${renderBlocks(l)}</div>
      <div class="lesson-foot">
        <button class="btn ${passed ? "btn-ghost" : "btn-primary"}" id="startQuiz">
          ${passed ? "复习测验 ✓" : `开始 ${l.quiz.length} 道小测验`}
        </button>
        <div id="quizArea"></div>
        ${idx + 1 < c.lessons.length
          ? `<button class="btn btn-line hidden" id="nextLesson" style="margin-top:10px">下一节：${esc(c.lessons[idx + 1].title)} →</button>`
          : `<button class="btn btn-accent hidden" id="backPath" style="margin-top:10px">${c.id === 7 ? "查看我的成就 🌳" : "返回学习路径 →"}</button>`}
        <p class="disclaim">本内容仅用于投资知识启蒙与教育，不构成任何投资建议。投资有风险，决策需谨慎。</p>
      </div>`,
      { cls: "page", tabbar: false, mounted() {
        $('[data-href]').addEventListener("click", e => go(e.currentTarget.dataset.href));
        $("#startQuiz").addEventListener("click", () => startQuiz(l, c, idx));
      } });
  }

  function startQuiz(l, c, idx) {
    const area = $("#quizArea");
    const answers = new Array(l.quiz.length).fill(null);
    function qcard(qi) {
      const q = l.quiz[qi];
      const letters = ["A", "B", "C", "D"];
      return `
        <div class="quiz-card" data-qi="${qi}">
          <div class="quiz-q"><span class="qidx">Q${qi + 1}.</span>${esc(q.q)}</div>
          ${q.options.map((op, oi) => `
            <button class="quiz-opt" data-oi="${oi}">
              <span class="opt-mark">${letters[oi]}</span><span>${esc(op)}</span>
            </button>`).join("")}
          <div class="quiz-explain"></div>
        </div>`;
    }
    area.innerHTML = l.quiz.map((_, i) => qcard(i)).join("") +
      `<div class="quiz-card center" id="qResult" style="display:none"></div>`;
    $("#startQuiz").style.display = "none";

    $$(".quiz-card[data-qi]").forEach(card => {
      const qi = +card.dataset.qi, q = l.quiz[qi];
      card.addEventListener("click", e => {
        const btn = e.target.closest(".quiz-opt");
        if (!btn || answers[qi] !== null) return;
        const oi = +btn.dataset.oi;
        answers[qi] = oi;
        const correct = oi === q.answer;
        $$(".quiz-opt", card).forEach((b, i) => {
          b.classList.add("disabled");
          if (i === q.answer) b.classList.add("correct");
          if (i === oi && !correct) b.classList.add("wrong");
          b.querySelector(".opt-mark").textContent = i === q.answer ? "✓" : (i === oi ? "✕" : letters[i]);
        });
        const ex = $(".quiz-explain", card);
        ex.innerHTML = `<strong>${correct ? "答对了！" : "差一点～"}</strong> ${esc(q.explain || "")}`;
        ex.classList.add("show");
        if (answers.every(a => a !== null)) showResult();
      });
    });

    function letters(i){return ["A","B","C","D"][i];}

    function showResult() {
      const correctCount = answers.filter((a, i) => a === l.quiz[i].answer).length;
      const allRight = correctCount === l.quiz.length;
      const res = $("#qResult");
      res.style.display = "block";
      if (allRight) {
        const isNew = S.passLesson(l.id);
        const lastLesson = idx + 1 === c.lessons.length;
        const lastChapter = c.id === 7;
        res.innerHTML = `
          <div class="quiz-result">
            <div style="width:96px;margin:0 auto 6px">${sprout("celebrate")}</div>
            <h3>全部答对，太棒了！</h3>
            <p>${isNew ? "本节已完成，进度已保存。" : "复习完成，记忆更牢固了。"}</p>
          </div>`;
        if (isNew) checkAchievements();
        const nextBtn = $("#nextLesson") || $("#backPath");
        if (nextBtn) {
          nextBtn.classList.remove("hidden");
          if (nextBtn.id === "nextLesson") nextBtn.addEventListener("click", () => go("#/lesson/" + c.lessons[idx + 1].id));
          else nextBtn.addEventListener("click", () => go(lastChapter ? "#/profile" : "#/"));
        }
      } else {
        res.innerHTML = `
          <div class="quiz-result">
            <div style="width:80px;margin:0 auto 6px">${sprout("sad")}</div>
            <h3>答对 ${correctCount} / ${l.quiz.length} 题</h3>
            <p>没关系，记住解析里的要点，再试一次就能通过～</p>
            <button class="btn btn-primary" id="retryQuiz">再做一次</button>
          </div>`;
        $("#retryQuiz").addEventListener("click", () => startQuiz(l, c, idx));
      }
      if (res.scrollIntoView) res.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  }

  /* ============ 工具箱首页 ============ */
  function vTools() {
    S.touchStreak();
    const tools = [
      { key: "compound", ico: "💰", cls: "tc-green", name: "复利计算器", desc: "拖一拖滑块，看时间的魔力" },
      { key: "dca", ico: "🧺", cls: "tc-orange", name: "定投计算器", desc: "定期定额，积少成多" },
      { key: "inflation", ico: "📉", cls: "tc-red", name: "通胀缩水", desc: "你的现金购买力会怎么变" },
      { key: "risk", ico: "🎯", cls: "tc-blue", name: "风险测评", desc: "8 题了解你的风险类型" },
      { key: "glossary", ico: "📖", cls: "tc-green", name: "术语词典", desc: "人话解释 40+ 理财词" }
    ];
    render(`
      <div class="page-head"><h1>🧰 工具箱</h1><p>动手玩一玩，体感比死记更牢。</p></div>
      <div class="tool-grid">
        ${tools.map(t => `
          <div class="tool-tile" data-tool="${t.key}">
            <div class="tt-ico ${t.cls}">${t.ico}</div>
            <h4>${esc(t.name)}</h4>
            <p>${esc(t.desc)}</p>
          </div>`).join("")}
      </div>
      <div class="card flat" style="margin-top:16px">
        <div style="font-size:13px;color:var(--ink-2);line-height:1.7">⚠️ 所有计算器结果均为<strong>数学模型示例</strong>，使用假设收益率，不代表对未来的预测，也不构成投资建议。</div>
      </div>`,
      { tabbar: true, tab: "tools", mounted() {
        $$(".tool-tile").forEach(el => el.addEventListener("click", () => go("#/tools/" + el.dataset.tool)));
      } });
  }

  /* ---------- 通用：滑块行 ---------- */
  function sliderRow(key, label, val, min, max, step, suffix, fmtFn) {
    return `
      <div class="slider-row" data-key="${key}">
        <div class="sr-top">
          <span class="sr-label">${esc(label)}</span>
          <span class="sr-val tnum">${fmtFn ? fmtFn(val) : val}${suffix || ""}</span>
        </div>
        <input type="range" min="${min}" max="${max}" step="${step}" value="${val}">
      </div>`;
  }

  /* ---------- 复利计算器 ---------- */
  function compoundModel(init, monthly, annual, years) {
    const r = annual / 100 / 12;
    const pts = [{ year: 0, total: init, principal: init }];
    let bal = init;
    for (let m = 1; m <= years * 12; m++) {
      bal = bal * (1 + r) + monthly;
      if (m % 12 === 0) pts.push({ year: m / 12, total: Math.round(bal), principal: Math.round(init + monthly * m) });
    }
    return pts;
  }

  function vToolCompound() {
    S.useTool("compound");
    const state = { init: 10000, monthly: 1000, annual: 8, years: 30 };
    function body() {
      const pts = compoundModel(state.init, state.monthly, state.annual, state.years);
      const last = pts[pts.length - 1];
      const gain = last.total - last.principal;
      return `
        ${topbar("#/tools", "复利计算器")}
        <div class="page-body">
          <div class="calc-result">
            <div class="cr-label">${state.years} 年后预计总额</div>
            <div class="cr-value tnum" id="fv">¥${fmt(last.total)}</div>
            <div class="cr-sub">
              <span>本金 ¥${fmt(last.principal)}</span>
              <span>收益 ¥${fmt(gain)}</span>
              <span>收益占比 ${pct(gain / last.total)}</span>
            </div>
          </div>
          <div class="chart-wrap">
            <div class="cw-title">
              增长曲线
              <span class="legend"><i style="background:var(--brand)"></i>总额</span>
              <span class="legend"><i style="background:var(--ink-3)"></i>本金</span>
            </div>
            <div id="chart"></div>
          </div>
          <div class="card">
            ${sliderRow("init", "初始本金", state.init, 0, 200000, 1000, " 元", v => v === 0 ? "0" : fmt(v))}
            ${sliderRow("monthly", "每月投入", state.monthly, 0, 20000, 100, " 元", fmt)}
            ${sliderRow("annual", "年化收益率", state.annual, 0, 20, 0.5, "%")}
            ${sliderRow("years", "持续年数", state.years, 1, 50, 1, " 年")}
          </div>
          <div class="risk-note">⚠️ 年化 8% 仅为示例假设，历史收益不代表未来，真实投资有亏有盈。</div>
        </div>`;
    }
    function paint() {
      view.innerHTML = body();
      bindTopBack();
      const pts = compoundModel(state.init, state.monthly, state.annual, state.years);
      $("#chart").innerHTML = lineChart({
        series: [
          { data: pts.map(p => p.total), color: "#2FA877", area: true },
          { data: pts.map(p => p.principal), color: "#AAAAAA" }
        ],
        xLabel: i => pts[i].year + "年",
        yFmt: v => v >= 10000 ? (v / 10000) + "万" : v
      });
      // 数字滚动
      const target = pts[pts.length - 1].total;
      const fv = $("#fv");
      const cur = parseInt((fv.textContent || "0").replace(/[^\d-]/g, "")) || 0;
      const start = performance.now();
      function tick(t) {
        const k = Math.min(1, (t - start) / 400);
        fv.textContent = "¥" + fmt(Math.round(cur + (target - cur) * k));
        if (k < 1) requestAnimationFrame(tick);
      }
      requestAnimationFrame(tick);
      $$(".slider-row").forEach(row => {
        const key = row.dataset.key, input = $("input", row), lbl = $(".sr-val", row);
        input.addEventListener("input", () => {
          state[key] = parseFloat(input.value);
          const f = key === "init" || key === "monthly" ? fmt : (v) => v;
          const suf = key === "annual" ? "%" : (key === "years" ? " 年" : " 元");
          lbl.innerHTML = (key === "init" && state[key] === 0 ? "0" : f(state[key])) + suf;
          paint();
        });
      });
    }
    view.className = "view page page-enter";
    view.innerHTML = "";
    showTabbar(false);
    paint();
  }

  /* ---------- 定投计算器 ---------- */
  function vToolDCA() {
    S.useTool("compound");
    const state = { monthly: 1000, annual: 8, years: 20 };
    function calc() { return compoundModel(0, state.monthly, state.annual, state.years); }
    function body() {
      const pts = calc();
      const last = pts[pts.length - 1];
      const gain = last.total - last.principal;
      return `
        ${topbar("#/tools", "定投计算器")}
        <div class="page-body">
          <div class="calc-result orange">
            <div class="cr-label">定投 ${state.years} 年后预计</div>
            <div class="cr-value tnum" id="fv">¥${fmt(last.total)}</div>
            <div class="cr-sub"><span>累计投入 ¥${fmt(last.principal)}</span><span>累计收益 ¥${fmt(gain)}</span></div>
          </div>
          <div class="card">
            <div style="display:flex;height:18px;border-radius:9px;overflow:hidden;margin:6px 0 10px">
              <div style="width:${pct(last.principal / last.total)};background:#3A86FF;color:#fff;font-size:11px;display:flex;align-items:center;justify-content:center">本金 ${pct(last.principal / last.total)}</div>
              <div style="flex:1;background:#F5A623;color:#fff;font-size:11px;display:flex;align-items:center;justify-content:center">收益 ${pct(gain / last.total)}</div>
            </div>
          </div>
          <div class="chart-wrap">
            <div class="cw-title">
              定投增长
              <span class="legend"><i style="background:#F5A623"></i>总额</span>
              <span class="legend"><i style="background:#3A86FF"></i>本金</span>
            </div>
            <div id="chart"></div>
          </div>
          <div class="card">
            ${sliderRow("monthly", "每月定投", state.monthly, 100, 20000, 100, " 元", fmt)}
            ${sliderRow("annual", "预期年化", state.annual, 0, 20, 0.5, "%")}
            ${sliderRow("years", "定投年数", state.years, 1, 50, 1, " 年")}
          </div>
          <div class="card flat">
            <div style="font-size:13px;color:var(--ink-2);line-height:1.7">
            <strong>定投的价值</strong>不在预测涨跌，而在纪律：高位少买、低位多买，自动摊平成本，克服择时焦虑。它需要<strong>长期坚持</strong>和<strong>闲钱</strong>，下跌时停止扣款是最常见的亏钱方式。
            </div>
          </div>
          <div class="risk-note">⚠️ 预期年化仅为示例，不代表未来收益，定投也可能亏损。</div>
        </div>`;
    }
    function paint() {
      view.innerHTML = body();
      bindTopBack();
      const pts = calc();
      $("#chart").innerHTML = lineChart({
        series: [
          { data: pts.map(p => p.total), color: "#F5A623", area: true },
          { data: pts.map(p => p.principal), color: "#3A86FF" }
        ],
        xLabel: i => pts[i].year + "年",
        yFmt: v => v >= 10000 ? (v / 10000) + "万" : v
      });
      const target = pts[pts.length - 1].total;
      const fv = $("#fv");
      const cur = parseInt((fv.textContent || "0").replace(/[^\d-]/g, "")) || 0;
      const s0 = performance.now();
      (function tick(t) {
        const k = Math.min(1, (t - s0) / 400);
        fv.textContent = "¥" + fmt(Math.round(cur + (target - cur) * k));
        if (k < 1) requestAnimationFrame(tick);
      })(s0);
      $$(".slider-row").forEach(row => {
        const key = row.dataset.key, input = $("input", row), lbl = $(".sr-val", row);
        input.addEventListener("input", () => {
          state[key] = parseFloat(input.value);
          lbl.innerHTML = (key === "monthly" ? fmt(state[key]) : state[key]) + (key === "annual" ? "%" : (key === "years" ? " 年" : " 元"));
          paint();
        });
      });
    }
    view.className = "view page page-enter";
    view.innerHTML = "";
    showTabbar(false);
    paint();
  }

  /* ---------- 通胀计算器 ---------- */
  function vToolInflation() {
    const state = { amount: 100000, infl: 3, years: 20 };
    function model() {
      const pts = [{ year: 0, nom: state.amount, real: state.amount }];
      for (let y = 1; y <= state.years; y++) {
        pts.push({ year: y, nom: state.amount, real: Math.round(state.amount / Math.pow(1 + state.infl / 100, y)) });
      }
      return pts;
    }
    function body() {
      const pts = model();
      const last = pts[pts.length - 1];
      const loss = state.amount - last.real;
      return `
        ${topbar("#/tools", "通胀缩水计算器")}
        <div class="page-body">
          <div class="calc-result red">
            <div class="cr-label">${state.years} 年后，这笔钱的购买力约等于</div>
            <div class="cr-value tnum" id="fv">¥${fmt(last.real)}</div>
            <div class="cr-sub"><span>名义仍为 ¥${fmt(last.nom)}</span><span>缩水 ${pct(loss / state.amount)}（¥${fmt(loss)}）</span></div>
          </div>
          <div class="chart-wrap">
            <div class="cw-title">
              名义金额 vs 实际购买力
              <span class="legend"><i style="background:#AAAAAA"></i>名义金额</span>
              <span class="legend"><i style="background:#E5544B"></i>实际购买力</span>
            </div>
            <div id="chart"></div>
          </div>
          <div class="card">
            ${sliderRow("amount", "当前金额", state.amount, 1000, 2000000, 1000, " 元", fmt)}
            ${sliderRow("infl", "年通胀率", state.infl, 0, 15, 0.5, "%")}
            ${sliderRow("years", "经过年数", state.years, 1, 50, 1, " 年")}
          </div>
          <div class="card flat"><div style="font-size:13px;color:var(--ink-2);line-height:1.7">
            如果钱一直放着不动，它的名义数字不会少，但能买到的东西会越来越少。<strong>理财的最低目标，是跑赢通胀。</strong>
          </div></div>
          <div class="risk-note">⚠️ 通胀率为假设值，不同时期通胀水平不同。</div>
        </div>`;
    }
    function paint() {
      view.innerHTML = body();
      bindTopBack();
      const pts = model();
      $("#chart").innerHTML = lineChart({
        series: [
          { data: pts.map(p => p.nom), color: "#AAAAAA" },
          { data: pts.map(p => p.real), color: "#E5544B", area: true }
        ],
        xLabel: i => pts[i].year + "年",
        yFmt: v => v >= 10000 ? (v / 10000) + "万" : v
      });
      const target = pts[pts.length - 1].real;
      const fv = $("#fv");
      const cur = parseInt((fv.textContent || "0").replace(/[^\d-]/g, "")) || 0;
      const s0 = performance.now();
      (function tick(t) {
        const k = Math.min(1, (t - s0) / 400);
        fv.textContent = "¥" + fmt(Math.round(cur + (target - cur) * k));
        if (k < 1) requestAnimationFrame(tick);
      })(s0);
      $$(".slider-row").forEach(row => {
        const key = row.dataset.key, input = $("input", row), lbl = $(".sr-val", row);
        input.addEventListener("input", () => {
          state[key] = parseFloat(input.value);
          lbl.innerHTML = (key === "amount" ? fmt(state[key]) : state[key]) + (key === "infl" ? "%" : (key === "years" ? " 年" : " 元"));
          paint();
        });
      });
    }
    view.className = "view page page-enter";
    view.innerHTML = "";
    showTabbar(false);
    paint();
  }

  /* ---------- 风险测评 ---------- */
  function vToolRisk() {
    const state = { i: 0, scores: [] };
    function qView() {
      const q = D.riskQuestions[state.i];
      return `
        ${topbar("#/tools", "风险承受力测评")}
        <div class="page-body">
          <div class="card">
            <div class="risk-progress">${D.riskQuestions.map((_, i) => `<i class="${i <= state.i ? "done" : ""}"></i>`).join("")}</div>
            <div class="muted small">第 ${state.i + 1} / ${D.riskQuestions.length} 题</div>
            <div class="risk-q mt12">${esc(q.q)}</div>
            ${q.options.map((o, i) => `<button class="risk-opt" data-i="${i}">${esc(o.t)}</button>`).join("")}
          </div>
          <p class="center small muted">本测评仅帮你粗略了解自己的风险偏好，不构成投资建议。</p>
        </div>`;
    }
    function resultView() {
      const total = state.scores.reduce((a, b) => a + b, 0);
      const type = D.riskTypes.find(t => total >= t.min && total <= t.max);
      S.setRiskResult(type.name);
      checkAchievements();
      const prev = S.getRiskResult();
      return `
        ${topbar("#/tools", "测评结果")}
        <div class="page-body">
          <div class="card">
            <div class="risk-result">
              <div style="width:96px;margin:0 auto 6px">${sprout("happy")}</div>
              <div class="muted small">你的测评得分 ${total} 分</div>
              <div class="risk-type" style="background:${type.color}22;color:${type.color}">${esc(type.name)}</div>
              <p class="muted" style="text-align:left;font-size:14px;line-height:1.8">${esc(type.desc)}</p>
              <div class="alloc-bar">${type.alloc.map(a => `<div style="width:${a.p}%;background:${a.c}">${a.p >= 12 ? a.p + "%" : ""}</div>`).join("")}</div>
              <div class="alloc-legend">
                ${type.alloc.map(a => `<div><i style="background:${a.c}"></i>${esc(a.n)} <span class="muted">约 ${a.p}%</span></div>`).join("")}
              </div>
            </div>
          </div>
          <div class="card flat"><div style="font-size:13px;color:var(--ink-2);line-height:1.7">
            上面的比例只是<strong>教学示意</strong>，帮助你理解「不同风险偏好对应不同的股债现金比例」，不是推荐的投资组合。真实配置还要考虑你的年龄、收入稳定性、家庭负担和投资期限。
          </div></div>
          <button class="btn btn-primary" id="retake">重新测一次</button>
        </div>`;
    }
    function show() {
      render(state.i < D.riskQuestions.length ? qView() : resultView(), { cls: "page", tabbar: false, mounted() {
        bindTopBack();
        if (state.i < D.riskQuestions.length) {
          $$(".risk-opt").forEach(b => b.addEventListener("click", e => {
            const card = e.currentTarget.closest(".card");
            if (card.dataset.done) return; // 防止快速点选导致重复计分
            card.dataset.done = "1";
            e.currentTarget.classList.add("selected");
            $$(".risk-opt", card).forEach(x => x.style.pointerEvents = "none");
            state.scores.push(+e.currentTarget.dataset.i);
            setTimeout(() => { state.i++; show(); }, 150);
          }));
        } else {
          $("#retake").addEventListener("click", () => { state.i = 0; state.scores = []; show(); });
        }
      }});
    }
    show();
  }

  /* ---------- 术语词典 ---------- */
  function vToolGlossary() {
    const cats = ["基础概念", "基金股票", "风险收益", "行为心理", "防骗识局"];
    function listHtml(filter) {
      const kw = (filter || "").trim().toLowerCase();
      let html = "";
      cats.forEach(cat => {
        const items = D.terms.filter(t => t.cat === cat && (!kw ||
          t.name.toLowerCase().indexOf(kw) >= 0 ||
          (t.aliases || []).some(a => a.toLowerCase().indexOf(kw) >= 0) ||
          t.short.toLowerCase().indexOf(kw) >= 0));
        if (!items.length) return;
        html += `<div class="glossary-cat">${esc(cat)} · ${items.length}</div>`;
        items.forEach(t => {
          html += `
            <div class="term-item" data-name="${esc(t.name)}">
              <div class="ti-name">${esc(t.name)}
                ${t.aliases && t.aliases.length ? `<span class="muted small" style="font-weight:400">（${esc(t.aliases.join("、"))}）</span>` : ""}
                <span class="ti-arrow">▾</span>
              </div>
              <div class="ti-short">${esc(t.short)}</div>
              <div class="ti-body">${esc(t.body)}${t.eg ? `<br><br><strong style="color:var(--brand-dark)">举个栗子：</strong>${esc(t.eg)}` : ""}</div>
            </div>`;
        });
      });
      if (!html) html = `<div class="empty-state"><div class="es-emo">🔍</div><p>没有找到相关术语</p></div>`;
      return html;
    }
    render(`
      ${topbar("#/tools", "术语词典")}
      <div class="page-body">
        <div class="search-box">
          <span class="s-ic">🔍</span>
          <input id="gSearch" type="text" placeholder="搜索术语，如「复利」「PE」" autocomplete="off">
        </div>
        <div id="gList">${listHtml("")}</div>
      </div>`, { cls: "page", tabbar: false, mounted() {
      bindTopBack();
      const inp = $("#gSearch"), list = $("#gList");
      inp.addEventListener("input", () => { list.innerHTML = listHtml(inp.value); });
      list.addEventListener("click", e => {
        const item = e.target.closest(".term-item");
        if (item) item.classList.toggle("open");
      });
    } });
  }

  /* ============ 我的 ============ */
  function vProfile() {
    S.touchStreak();
    const tp = S.totalProgress();
    const chDone = D.chapters.filter(c => c.lessons.every(l => S.isPassed(l.id))).length;
    const got = S.getAchievements();
    const streak = S.getStreak();
    const qi = Math.floor((new Date().getTime() / 86400000)) % D.quotes.length;
    const q = D.quotes[qi];
    const badges = S.ACH.map(a => {
      const on = got.indexOf(a.id) >= 0;
      return `<div class="badge ${on ? "" : "locked"}">
        ${on ? '<div class="b-check">✓</div>' : ""}
        <div class="b-ico">${a.emoji}</div>
        <div class="b-name">${esc(a.name)}</div>
        <div class="b-desc">${esc(a.desc)}</div>
      </div>`;
    }).join("");

    render(`
      <div class="profile-head">
        <div class="ph-name">我的财小苗 🌱</div>
        <div class="ph-sub">从零开始，慢慢变富</div>
        <div class="stat-grid">
          <div class="sg"><div class="n tnum">${chDone}/7</div><div class="l">学完章节</div></div>
          <div class="sg"><div class="n tnum">${tp.done}/${tp.total}</div><div class="l">完成小节</div></div>
          <div class="sg"><div class="n tnum">${streak}</div><div class="l">连续天数</div></div>
        </div>
      </div>
      <div class="tab-body">
      <div class="daily-card">
        <div class="dc-label">📅 每日一签</div>
        <div class="dc-text">「${esc(q.t)}」</div>
        <div class="dc-from">${esc(q.f)}</div>
      </div>
      <div class="section-title">我的徽章（${got.length}/${S.ACH.length}）</div>
      <div class="badge-grid">${badges}</div>
      <div class="section-title">更多</div>
      <div class="card" style="padding:4px 18px">
        <div class="menu-row" id="mRisk"><div class="mr-ico tc-blue">🎯</div><div class="mr-label">${S.getRiskResult() ? "我的风险类型：" + S.getRiskResult() : "测一测我的风险承受力"}</div><div class="mr-arrow">›</div></div>
        <div class="menu-row" id="mAbout"><div class="mr-ico tc-green">ℹ️</div><div class="mr-label">关于与免责声明</div><div class="mr-arrow">›</div></div>
        <div class="menu-row danger" id="mReset"><div class="mr-ico">🗑️</div><div class="mr-label">重置全部进度</div><div class="mr-arrow">›</div></div>
      </div>
      </div>`,
      { cls: "page", tabbar: true, tab: "profile", mounted() {
        $("#mRisk").addEventListener("click", () => go("#/tools/risk"));
        $("#mAbout").addEventListener("click", () => go("#/about"));
        $("#mReset").addEventListener("click", () => {
          Cxm.confirm({
            title: "重置全部进度？",
            content: "这会清空所有已学课程、测验结果、徽章和测评记录，且无法恢复。",
            okText: "确认重置", danger: true,
            onOk() { S.resetAll(); Cxm.toast("已重置，欢迎重新开始"); go("#/onboarding"); }
          });
        });
      } });
  }

  /* ============ 关于 / 免责 ============ */
  function vAbout() {
    render(`
      ${topbar("#/profile", "关于财小苗")}
      <div class="view no-tab about" style="padding-top:0">
        <div class="card center">
          <div style="width:80px;margin:4px auto 8px">${sprout("happy")}</div>
          <h2 style="font-size:20px">财小苗</h2>
          <div class="muted small">版本 1.0 · 投资认知启蒙</div>
        </div>
        <div class="card">
          <h4>这是什么？</h4>
          <p>财小苗是一款纯公益、纯离线的投资认知启蒙应用，面向零基础的「小白」。它不荐股、不交易、不收集任何个人信息。</p>
          <h4>我们坚持</h4>
          <p>✅ 内容教育化：只讲认知与方法，不推任何具体产品代码<br>
             ✅ 全程离线：无需网络权限，飞行模式可用<br>
             ✅ 隐私优先：不登录、不上报、不含第三方 SDK</p>
        </div>
        <div class="card">
          <h4>⚠️ 免责声明</h4>
          <div class="disclaim-box">
            本应用提供的所有内容（包括但不限于课程、测验、计算器、风险测评、术语解释）<strong>仅用于金融知识普及与教育目的</strong>，不构成任何投资建议、要约或承诺。<br><br>
            文中涉及的收益率、比例、年限等均为教学示例，不代表对未来的预测。投资有风险，入市需谨慎。投资者应根据自身情况独立决策，必要时咨询持牌专业机构。<br><br>
            本应用不对因使用本内容而作出的投资决策承担任何责任。
          </div>
        </div>
        <div class="ver">财小苗 v1.0 · 愿你慢慢变富 🌳</div>
      </div>`, { cls: "page", tabbar: false, mounted() { bindTopBack(); } });
  }

  function bindTopBack() {
    const b = $(".topbar .back");
    if (b) b.addEventListener("click", () => go(b.dataset.href));
  }

  /* ---------------- 路由分发 ---------------- */
  function route() {
    let hash = location.hash.replace(/^#/, "") || "/";
    // 未引导则强制进引导
    if (!S.isOnboarded() && hash !== "/onboarding") {
      location.replace("#/onboarding");
      return;
    }
    const parts = hash.split("/").filter(Boolean); // [] or ['chapter','1'] or ['tools','compound']
    try {
      if (parts.length === 0) return vLearn();
      if (parts[0] === "onboarding") return vOnboarding();
      if (parts[0] === "chapter" && parts[1]) return vChapter(parts[1]);
      if (parts[0] === "lesson" && parts[1]) return vLesson(parts[1]);
      if (parts[0] === "tools" && !parts[1]) return vTools();
      if (parts[0] === "tools") {
        const t = parts[1];
        if (t === "compound") return vToolCompound();
        if (t === "dca") return vToolDCA();
        if (t === "inflation") return vToolInflation();
        if (t === "risk") return vToolRisk();
        if (t === "glossary") return vToolGlossary();
      }
      if (parts[0] === "profile") return vProfile();
      if (parts[0] === "about") return vAbout();
      go("/");
    } catch (e) {
      console.error(e);
      view.innerHTML = `<div class="empty-state"><div class="es-emo">😵</div><p>页面出错了</p></div>`;
    }
  }

  /* ---------------- 初始化 ---------------- */
  function init() {
    // Tab 点击
    $$("#tabbar .tab").forEach(t => t.addEventListener("click", () => {
      if (!t.classList.contains("active")) location.hash = t.dataset.route;
    }));
    // 全局事件代理：术语点按、章节卡片
    view.addEventListener("click", e => {
      const term = e.target.closest(".term");
      if (term) { openTerm(term.dataset.term); return; }
      const ch = e.target.closest(".tl-card[data-chapter]");
      if (ch) {
        const node = ch.closest(".tl-node");
        if (node && node.classList.contains("locked")) { Cxm.toast("先完成上一章哦"); return; }
        go("#/chapter/" + ch.dataset.chapter);
      }
    });

    window.addEventListener("hashchange", route);
    route();
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
