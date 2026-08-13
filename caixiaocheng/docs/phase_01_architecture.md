# 阶段一交付物：认知架构与数据模型

> 产品名：**财小橙 · 7 天投资入门**（暂定）
> 定位：给 35 岁左右、月薪 8K–20K、对股票基金零基础甚至畏惧的职场人
> 使命：用大白话 + 互动游戏，7 天建立受用一生的投资底层认知

---

## 一、认知金字塔模型（4 层进阶）

### 为什么是这个顺序？（科学性说明）

四层遵循「**观念 → 工具 → 方法 → 心性**」的学习规律，对齐教育心理学中的认知进阶：

1. 先解决「钱是什么、为什么会变少」——这是**安全感**问题，不解决就无法谈投资；
2. 再认识工具——这是**词汇表**，没有词汇表无法讨论策略；
3. 然后学策略——这是**方法论**，需要工具知识做地基；
4. 最后修心性——这是**元认知**，90% 的人亏钱不是不懂方法，而是输给情绪，必须放在最后，因为它需要前三段的真实体感才能听懂。

每层通关条件：**本章测验正确率 ≥ 80%**，并完成至少 1 个模拟决策。

```
                    ▲  Lv.4 心法篇 「铂金守心人」
                   ╱ ╲   韭菜心理 · 新闻辨别 · 情绪纪律
                  ╱───╲
                 ╱ Lv.3╲ 「黄金规划师」
                ╱ 策略篇 ╲  复利72法则 · 微笑曲线 · 仓位 · 长期主义
               ╱─────────╲
              ╱   Lv.2    ╲「白银学徒」
             ╱   工具篇     ╲ 股票·债券·基金·保险 的本质
            ╱───────────────╲
           ╱     Lv.1         ╲「青铜小白」
          ╱      扫盲篇         ╲ 通胀·购买力·CPI·存款国债理财区别
         ╱───────────────────────╲
```

### Lv.1 扫盲篇 ——「青铜小白」
- **核心问题**：我的钱为什么在变少？
- **学习目标**：理解通胀、CPI、购买力；能分清存款/国债/银行理财的风险差异；建立「理财≠炒股」的第一观念。
- **关键概念**：通货膨胀、CPI、购买力、名义收益 vs 实际收益、72 法则（启蒙）、单利复利。
- **生活类比主线**：把钱埋地下的蔬菜 / 冰箱里慢慢烂掉的菜。
- **通关后获得的能力**：不再把所有钱存活期，看懂「年化 3% 跑不赢通胀」是什么意思。

### Lv.2 工具篇 ——「白银学徒」
- **核心问题**：市面上的理财工具到底是什么？
- **学习目标**：用人话理解股票=公司所有权、债券=借条、基金=雇人帮你买、保险=兜底；知道各自的风险等级和适用场景。
- **关键概念**：股权、债权、基金净值、分散、费率、保障型 vs 理财型保险。
- **生活类比主线**：开餐馆自负盈亏 / 把钱交给米其林大厨打理 / 给生意上保险。
- **通关后获得的能力**：看到一只基金/股票/保险产品，能说出它本质是什么、风险大概在哪。

### Lv.3 策略篇 ——「黄金规划师」
- **核心问题**：我该怎么买、买多少、拿多久？
- **学习目标**：理解复利与 72 法则、定投微笑曲线与平均成本法、仓位/分散、长期主义与短期投机的区别。
- **关键概念**：复利、72 法则、定投、平均成本、微笑曲线、仓位、再平衡、止盈止损。
- **互动模拟器**：输入「每月 1000 元、年化 8%」本地算出 5 年/10 年/30 年的钱（Dart 纯计算，无网络）。
- **通关后获得的能力**：能给自己写出一份极简定投计划，知道为什么下跌时不能停。

### Lv.4 心法篇 ——「铂金守心人」
- **核心问题**：为什么道理都懂，还是亏钱？
- **学习目标**：识别追涨杀跌、损失厌恶、羊群效应、幸存者偏差、沉没成本；学会「看新闻但不被新闻牵着走」。
- **关键概念**：行为偏差、FUD/FOMO、幸存者偏差、沉没成本、独立思考。
- **通关仪式**：完成「模拟市场暴跌」压力测试，验证自己是否拿得住。
- **通关后获得的能力**：面对大跌和爆款新闻时，有一套自己的应对清单，而不是凭情绪操作。

---

## 二、本地数据库 Schema 设计（SQLite / sqflite）

### 设计原则

1. **内容与状态分离**：`assets/data/*.json` 是只读内容源；首启时写入 SQLite 的「内容表」，用户行为写「状态表」。这样日后替换 JSON 即可更新课程，且不丢进度。
2. **内容表带 `content_version`**：支持后续热更 JSON 后增量迁移。
3. **外键约束 + 索引**：保证数据完整性与查询性能。
4. **所有时间用 ISO8601 字符串**（`DateTime.toIso8601String()`），避免时区坑。
5. **状态表可离线工作**：完全不依赖网络，契合「零后台」。

### 2.1 内容表（由 JSON 灌库）

```sql
-- 内容版本表：控制 JSON 升级时重新灌库
CREATE TABLE app_meta (
  key   TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
-- 预置：('content_version','1'), ('db_version','1'), ('first_launch_at','...')

-- 章节表（对应认知金字塔 4 层，每层可含 1~N 章；v1 为 4 章）
CREATE TABLE chapters (
  id                    TEXT PRIMARY KEY,          -- 'C1'..'C4'
  level                 INTEGER NOT NULL,          -- 金字塔层级 1~4
  order_index           INTEGER NOT NULL,
  title                 TEXT NOT NULL,             -- '钱的世界观'
  subtitle              TEXT,
  description           TEXT,
  cover_emoji           TEXT DEFAULT '🍊',
  theme_color           TEXT DEFAULT '#FF8C42',
  unlock_type           TEXT NOT NULL DEFAULT 'prev_chapter',
  -- none(首章) / prev_chapter(上一章通关) / quiz_rate(本章测验达标)
  unlock_ref            TEXT,                      -- 依赖的章节 id，如 'C1'
  required_correct_rate REAL DEFAULT 0.8,          -- 解锁所需正确率 80%
  required_quiz_count   INTEGER DEFAULT 3,         -- 本章测验题数下限
  estimated_minutes     INTEGER DEFAULT 10,
  is_locked_default     INTEGER DEFAULT 1
);
CREATE INDEX idx_chapters_level ON chapters(level, order_index);

-- 知识卡片表（80+ 节点，每张卡 = 信息流里一屏）
CREATE TABLE cards (
  id                TEXT PRIMARY KEY,              -- 'C1_001'
  chapter_id        TEXT NOT NULL,
  order_index       INTEGER NOT NULL,
  title             TEXT NOT NULL,
  daily_analogy     TEXT NOT NULL,                 -- 生活类比（买菜/开奶茶店）
  core_knowledge    TEXT NOT NULL,                 -- 大白话核心知识
  illustration_note TEXT,                          -- 插画/动画描述
  content_json      TEXT,                          -- 图文混排结构化段落(JSON数组)
  related_quiz_id   TEXT,                          -- 卡末关联小测
  glossary_terms    TEXT,                          -- 文中术语，JSON数组，点击查词典
  points            INTEGER DEFAULT 10,            -- 右滑「懂了」积分
  difficulty        INTEGER DEFAULT 1,             -- 1~3
  FOREIGN KEY (chapter_id) REFERENCES chapters(id)
);
CREATE INDEX idx_cards_chapter ON cards(chapter_id, order_index);

-- 测验题表（每章 3~5 题，闯关用；也可被卡片引用做卡末小测）
CREATE TABLE quizzes (
  id            TEXT PRIMARY KEY,                  -- 'QZ_C1_01'
  chapter_id    TEXT NOT NULL,
  card_id       TEXT,                              -- 可挂靠到具体卡片
  order_index   INTEGER NOT NULL,
  question      TEXT NOT NULL,
  options       TEXT NOT NULL,                     -- JSON: ["A..","B..","C..","D.."]
  answer_index  INTEGER NOT NULL,                  -- 正确项下标 0-based
  explanation   TEXT NOT NULL,                     -- 解析 + 俏皮话
  wrong_reply   TEXT,                              -- 答错专属俏皮话
  right_reply   TEXT,                              -- 答对专属夸奖
  points        INTEGER DEFAULT 20,
  FOREIGN KEY (chapter_id) REFERENCES chapters(id)
);
CREATE INDEX idx_quizzes_chapter ON quizzes(chapter_id, order_index);

-- 模拟决策场景表（「模拟人生」文字分支）
CREATE TABLE simulations (
  id                   TEXT PRIMARY KEY,           -- 'SIM_01'
  chapter_id           TEXT,
  order_index          INTEGER NOT NULL,
  title                TEXT NOT NULL,              -- '2018年，你有5万块闲钱'
  background           TEXT NOT NULL,              -- 场景背景铺陈
  era_year             INTEGER,                    -- 假设的历史年份
  initial_amount       REAL DEFAULT 100000,        -- 虚拟初始资金(积分)
  options              TEXT NOT NULL,
  -- JSON: [{"key":"A","text":"存银行定期","outcome":"三年后…","pnl_pct":6.0,
  --        "emoji":"🏦","takeaway":"…","followup":"SIM_02"}]
  UNIQUE(chapter_id, order_index)
);

-- 一句话词典表（底部常驻悬浮窗）
CREATE TABLE glossary (
  term            TEXT PRIMARY KEY,                -- 'ROE'
  aliases         TEXT,                            -- JSON: ["净资产收益率"]
  one_line        TEXT NOT NULL,                   -- ≤20字大白话
  full_explain    TEXT,                            -- 点开后详细解释
  daily_analogy   TEXT,                            -- 配套生活类比
  related_card_id TEXT
);
```

### 2.2 状态表（用户行为 / 进度）

```sql
-- 用户全局状态（单行表，id 恒为 1）
CREATE TABLE user_status (
  id                   INTEGER PRIMARY KEY CHECK (id = 1),
  nickname             TEXT DEFAULT '小白',
  current_level        INTEGER DEFAULT 1,          -- 当前金字塔层级
  rank_title           TEXT DEFAULT '青铜小白',    -- 段位称号
  total_points         INTEGER DEFAULT 0,          -- 虚拟积分（非货币）
  current_chapter_id   TEXT DEFAULT 'C1',
  cards_read_count     INTEGER DEFAULT 0,
  quizzes_passed_count INTEGER DEFAULT 0,
  daily_streak         INTEGER DEFAULT 0,          -- 连续签到天数
  last_daily_date      TEXT,                       -- 最近挑战日期 YYYY-MM-DD
  crash_sim_used       INTEGER DEFAULT 0,          -- 是否体验过暴跌模拟
  created_at           TEXT NOT NULL,
  updated_at           TEXT NOT NULL,
  FOREIGN KEY (current_chapter_id) REFERENCES chapters(id)
);

-- 卡片阅读流水（每次滑动都记，支持统计与复习）
CREATE TABLE card_reads (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  card_id       TEXT NOT NULL,
  swipe_status  TEXT NOT NULL,   -- 'got'懂了(+分) / 'review'没懂(入复习队列)
  earned_points INTEGER DEFAULT 0,
  read_at       TEXT NOT NULL,
  FOREIGN KEY (card_id) REFERENCES cards(id)
);
CREATE INDEX idx_card_reads_card ON card_reads(card_id);

-- 待复习队列（左滑「没懂」的卡片，之后重学）
CREATE TABLE review_queue (
  card_id       TEXT PRIMARY KEY,
  added_at      TEXT NOT NULL,
  review_count  INTEGER DEFAULT 0,
  mastered      INTEGER DEFAULT 0,                -- 0待复习 1已掌握
  FOREIGN KEY (card_id) REFERENCES cards(id)
);

-- 测验作答记录（可多次作答，取最高分用于解锁判断）
CREATE TABLE quiz_attempts (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  chapter_id    TEXT NOT NULL,
  correct_count INTEGER NOT NULL,
  total_count   INTEGER NOT NULL,
  correct_rate  REAL NOT NULL,                    -- 0.0~1.0
  passed        INTEGER NOT NULL,                 -- 是否≥80%
  points_earned INTEGER DEFAULT 0,
  attempted_at  TEXT NOT NULL
);
CREATE INDEX idx_quiz_att_chapter ON quiz_attempts(chapter_id);

-- 模拟决策记录
CREATE TABLE sim_attempts (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  sim_id        TEXT NOT NULL,
  chosen_key    TEXT NOT NULL,                    -- 'A'/'B'/'C'
  pnl_pct       REAL,                             -- 假设盈亏百分比
  points_earned INTEGER DEFAULT 0,
  attempted_at  TEXT NOT NULL
);

-- 成长树果实（每通关一章结一个果实）
CREATE TABLE growth_fruits (
  id            TEXT PRIMARY KEY,                 -- 'FRUIT_C1'
  chapter_id    TEXT NOT NULL UNIQUE,
  skill_label   TEXT NOT NULL,                    -- '看懂通胀与购买力'
  emoji         TEXT DEFAULT '🍊',
  unlocked      INTEGER DEFAULT 0,
  unlocked_at   TEXT,
  FOREIGN KEY (chapter_id) REFERENCES chapters(id)
);

-- 每日早餐挑战记录（每天 3 道判断题）
CREATE TABLE daily_records (
  date          TEXT PRIMARY KEY,                 -- YYYY-MM-DD
  correct_count INTEGER DEFAULT 0,
  total_count   INTEGER DEFAULT 3,
  points_earned INTEGER DEFAULT 0,
  finished      INTEGER DEFAULT 0
);
```

### 2.3 种子数据初始化（伪代码）

```dart
// 首启逻辑：
// 1. 读取 assets/data/knowledge_base.json（含 chapters/cards/quizzes/simulations/glossary）
// 2. 事务批量 insert 到上述内容表
// 3. insert user_status (id=1, created_at=now, ...)
// 4. app_meta 写入 content_version / first_launch_at
// 升级逻辑：若 JSON 的 content_version > 库内版本，
//   内容表事务替换（INSERT OR REPLACE），状态表全部保留。
```

---

## 三、页面结构与交互路线图

### 3.1 信息架构（底部 4 Tab）

```
财小橙
├── 🏠 首页 Home
│   ├── 顶部：段位徽章「青铜小白 Lv.1」+ 虚拟积分
│   ├── 认知成长树（4 段树枝 + 果实）
│   ├── 4 个章节入口（锁定显示灰锁🔒 + 解锁条件提示）
│   └── 每日早餐挑战入口（3 道判断题 / 连击火苗）
│
├── 🎴 学习 Learn（核心）
│   ├── 顶部圆环进度条（本章完成度 %）
│   ├── 卡片堆叠：上滑/右滑「懂了 ✓ 加积分」，左滑「没懂 ↺ 进复习」
│   ├── 点术语 → 底部弹出「一句话词典」气泡
│   └── 滑完本章卡片 → 弹窗进入「闯关测验」
│
├── 🎲 模拟 Sim（模拟人生）
│   ├── 场景卡片：年份 + 背景 + 初始虚拟资金
│   ├── A/B/C 选项按钮
│   └── 选择后揭晓假设结局（历史化叙事 + 盈亏数字 + 道理）
│
└── 🍊 我的 Me（我的资产）
    ├── 虚拟积分明细（看卡/测验/模拟/每日）
    ├── 🔴「模拟市场暴跌」红按钮（-20% 压力测试 + 心理按摩）
    ├── 待复习卡片数、成长树果实收集
    ├── 一句话词典搜索（常驻输入框）
    └── 设置（重置进度 / 免责声明 / 关于）
```

### 3.2 核心交互流程

#### 流程 A：首次启动 → 完成第一章

```
启动 → 首启动画（暖橙 + 小橙人欢迎）
     → 首页：Lv.1 青铜小白，仅 C1 解锁，C2/C3/C4 灰色锁🔒
     → 点 C1「钱的世界观」
     → 学习页：圆环 0%，第一张卡片（通胀：冰箱里烂掉的菜🥬）
        ├─ 右滑「懂了」→ +10 积分，下一张
        ├─ 左滑「没懂」→ 俏皮话「没关系，这题确实绕，先存着回头看！」→ 入复习队列
        └─ 点术语「CPI」→ 底部气泡：「CPI=菜价涨了多少的官方记账本」
     → 15 张卡片滑完 → 弹窗「敢不敢来 5 道闯关题？」
     → 测验页：逐题选择
        ├─ 答对：「这都难不倒你！+20 分」
        └─ 答错：「哎呀，这是 90% 新手都会踩的坑哦，记住啦！」+解析
     → 结算：正确率 ≥80% → C2 解锁动画（成长树结出果实🍊「看懂通胀与购买力」）
              <80% → 「差一点点！再看一遍错题，咱们再战」→ 可重做
```

#### 流程 B：模拟人生

```
模拟页 → 场景「2018 年，你有 5 万块闲钱，工资稳定但没存款」
        A. 存银行 3 年定期（年化 ~2%）
        B. 一次性买入某宽基指数基金
        C. 放余额宝里观望
→ 用户点 B → 揭晓：
   「2018 年贸易摩擦，账户一度浮亏 -25%，你晚上睡不着……
    但你咬牙没卖，2019-2020 反弹，3 年后总资产约 5.75 万，收益 +15%。
    同期 A 方案约 +6%，C 方案约 +7%。」
   → 道理卡：波动 ≠ 风险，前提是闲钱 + 拿得住。
   → +积分（无论选哪个都有分，鼓励体验，不惩罚选择）
```

#### 流程 C：紧急避险压力测试（我的页红按钮）

```
点「🔴 模拟市场暴跌」→ 全屏红色动效 → 虚拟资产瞬间 -20%
→ 弹出三选一：
   A. 赶紧全卖了止损
   B. 装死不看
   C. 按计划继续定投
→ 选 A：「历史上恐慌割肉往往卖在最低点……记住这种心跳，下次别动手。」
  选 C：「这才是正确答案👍 定投者靠纪律穿越牛熊。」
→ 平复文案：「这只是模拟。真实投资请用闲钱、提前写好计划。」
```

### 3.3 章节解锁状态机

```
C1 ──测验≥80%──▶ C2 ──测验≥80%──▶ C3 ──测验≥80%──▶ C4 ──▶ 通关🎉
 ▲                                                       │
 └───────────────  任意章节可回看不影响已解锁状态  ────────┘
```

- 解锁判断由 Provider 读取 `quiz_attempts` 中该章最高 `correct_rate`。
- 已解锁章节永久开放复习；复习不影响已获积分。

### 3.4 视觉与交互规范（对齐你的 UI 要求）

| 项 | 规范 |
|---|---|
| 主色 | `#FF8C42`（暖橙）；强调/奖励色 `#FFB347`；警示暴跌用 `#E85D5D`（克制） |
| 背景 | `#FFF8F0`（奶白）；卡片纯白 `#FFFFFF`，圆角 20，柔和阴影 |
| 正文字号 | **18–20px**，行距 **1.8**，降低阅读焦虑 |
| 字体 | 系统无衬线（PingFang/思源黑体感），数字用等宽 |
| 卡片滑动 | 右滑「懂了 ✓」绿色轻反馈、左滑「没懂 ↺」橙色；阈值 30% 触发，带阻尼 |
| 答错反馈 | 永远不用红色大叉+「错误」字样；用俏皮话 + 解析 |
| 吉祥物 | 「小橙人」——一个圆滚滚的橙子，表情随场景：认真/开心/惊吓/鼓励 |
| 动效 | 页面 250ms ease-out；果实结出时有弹跳 + 撒花（轻量，不扰民） |
| 无障碍 | 触控目标 ≥48px；颜色不作为唯一信息载体（✓/↺ 图标配合） |

### 3.5 技术分层预告（为阶段三铺路）

```
lib/
├── main.dart
├── app.dart                      // MaterialApp + Provider 注入 + 主题
├── core/
│   ├── theme/app_theme.dart      // 暖橙主题、字号、圆角
│   ├── db/database_helper.dart   // sqflite 初始化、版本迁移、JSON 灌库
│   └── utils/finance_math.dart   // 复利/定投公式（阶段三重点注释）
├── data/
│   ├── models/                   // Chapter/Card/Quiz/Simulation/...
│   └── repositories/             // ChapterRepository 等，封装 SQL
├── providers/
│   ├── user_provider.dart        // 段位、积分、解锁状态
│   ├── learn_provider.dart       // 卡片队列、滑动、圆环进度
│   └── sim_provider.dart
├── features/
│   ├── home/                     // 首页 + 成长树
│   ├── learn/                    // 卡片流 + 测验
│   ├── simulation/               // 模拟人生
│   ├── assets/                   // 我的资产 + 暴跌按钮
│   └── daily/                    // 每日早餐挑战
└── widgets/
    ├── orange_maskot.dart        // 小橙人
    ├── glossary_sheet.dart       // 一句话词典底部弹层
    └── circular_progress.dart   // 圆环进度
assets/data/
├── knowledge_base.json           // 80+ 节点（阶段二交付）
├── glossary.json
├── simulations.json
└── daily_challenges.json
```

---

## 阶段一交付物清单（自检）

- [x] 认知金字塔 4 层模型（含科学性排序说明、段位称号、通关条件）
- [x] 5 张要求表的完整 `CREATE TABLE`（chapters / cards / quizzes / simulations / user_status）
- [x] 补充 7 张配套表（card_reads / review_queue / quiz_attempts / sim_attempts / growth_fruits / daily_records / glossary）+ 索引与外键
- [x] 内容与状态分离、JSON 灌库/升级方案
- [x] 5 个页面结构 + 底部 Tab 信息架构
- [x] 3 条核心交互流程（首次学习通关 / 模拟人生 / 暴跌压力测试）
- [x] 章节解锁状态机
- [x] 视觉与交互规范（暖橙、大字号、俏皮话、无大红大绿）
- [x] 技术分层目录预告

---

**请确认阶段一是否通过。** 确认后我将进入**阶段二：内容生产**，交付完整的 `knowledge_base.json`（≥80 个知识节点、≥20 个生活类比、4 章完整内容、卡片 JSON 严格按你给的格式）。
