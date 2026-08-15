# 财小橙 · uni-app 版架构设计文档

> 把现有 Flutter 版重写为 **uni-app（Vue3 + Vite）**，一套代码同时编译出 **微信小程序** 与 **H5**，并全面搭建用户系统。
> 文档日期：2026-08-15

---

## 1. 为什么这么做（背景与决策）

- 现有 Flutter 版产品力强但**无分发**（"安装未知来源 APK"+无账号+无推送），获客成本趋于无穷。
- 定下"个人影响力"路线后，需要一个能嵌进公众号、能被小红书/B站引流的**轻量入口**——小程序+H5 是唯一同时满足"分发+私域沉淀"的形态。
- 用户系统（登录+管理+进度云同步）从 V2 并入 V1，解决"纯离线无账号=无留存"的第二痛点。

## 2. 技术选型

| 层 | 选型 | 理由 |
|---|---|---|
| 框架 | **uni-app Vue3 + Vite** | 一套代码出小程序+H5；H5 可嵌公众号文章，与 IP 路线双押 |
| 状态 | **Pinia** | Vue3 官方推荐，轻量，SSR 友好 |
| 后端 | **uniCloud（阿里云）** | uni-app 官方云，跨小程序/H5 统一，免运维，有免费额度 |
| 用户体系 | **uni-id-common** | 官方用户系统，支持微信登录/手机号/token，省去自研鉴权 |
| 样式 | **SCSS + uni.scss 变量** | 移植 Flutter 设计 token，全 App 统一 |
| 内容 | **knowledge_base.json 原样复用** | 唯一能从 Flutter 直接搬运的资产 |

> 不选原生小程序：拿不到 H5，与公众号嵌落地页路线不咬合。
> 不选 Taro：uni-app 对小程序生态支持更原生，uniCloud 一体化。

## 3. 工程结构

```
miniprogram/                          # 本目录(uni-app 前端工程，仓库根下与 backend/ 同级)
├── package.json / vite.config.js / index.html
├── src/
│   ├── main.js                      # 入口(createSSRApp + Pinia)
│   ├── App.vue                      # onLaunch: 初始化 store、判断引导页
│   ├── pages.json                   # 路由 + tabBar + globalStyle
│   ├── manifest.json                # 小程序appid / uniCloud 服务空间 / h5
│   ├── uni.scss                     # 设计 token(暖橙主题)
│   ├── data/knowledge_base.json     # 内容(从 Flutter 原样复用)
│   ├── utils/
│   │   ├── finance.js               # 金融计算(移植 finance_math.dart)
│   │   ├── storage.js               # 本地存储封装(uni.setStorage)
│   │   ├── content.js               # 内容加载与查询(卡片/术语/书/题)
│   │   └── format.js                # 数字/金额格式化
│   ├── store/
│   │   ├── app.js                   # 学习状态:积分/段位/进度/复习队列/连击
│   │   └── user.js                  # 用户状态:登录态/token/资料/云同步
│   ├── components/                  # OrangeMascot/CircleProgress/SwipeCard/GlossarySheet/Disclaimer
│   └── pages/
│       ├── onboarding/onboarding    # 首启 3 屏引导
│       ├── home/home                # Tab1 首页(段位卡/成长树/每日入口)
│       ├── learn/learn              # Tab2 章节列表
│       ├── learn/chapter            # 章节详情(卡片列表)
│       ├── learn/swipe              # 滑卡学习(右滑懂了/左滑没懂)
│       ├── learn/quiz               # 闯关测验(8题≥80%解锁)
│       ├── learn/review             # 复习队列
│       ├── simulation/simulation    # Tab3 模拟入口
│       ├── simulation/compound      # 复利计算器
│       ├── simulation/dca           # 定投计算器
│       ├── simulation/inflation     # 通胀缩水计算器
│       ├── simulation/sim-life      # 模拟人生(穿越年份做选择)
│       ├── risk/risk-quiz           # 风险测评5题
│       ├── daily/daily              # 每日3分钟挑战
│       ├── books/bookshelf          # 经典书架16本
│       ├── books/book-detail        # 书籍导读详情
│       ├── mine/mine                # Tab4 我的(数据/成就/登录入口)
│       ├── mine/crash               # 暴跌演练
│       ├── mine/about               # 关于与免责声明
│       └── login/login              # 登录页(微信/手机号)
└── (后端已抽离到仓库根 ../backend/)
```

> 后端结构见 `../backend/`：`cloudfunctions/user-center/`（登录/登出/资料/手机号/进度同步）+ `database/cxch-user-progress.schema.json`（学习进度表，按 uid）。

## 4. 设计系统（移植自 Flutter app_theme.dart）

| Token | 值 | 用途 |
|---|---|---|
| `$primary` | `#FF8C42` | 暖橙主色 |
| `$primaryDark` | `#E5732A` | 按下/深色 |
| `$cream` | `#FFF8F0` | 奶白背景 |
| `$ink` | `#3D2B1F` | 暖棕黑正文 |
| `$ink2` | `#8A7A6D` | 次要文字 |
| `$line` | `#F0E6D8` | 分割线 |
| `$success` | `#6FB47A` | 柔绿(答对) |
| `$danger` | `#E86A5C` | 暴跌红(克制) |
| 段位色 | 青铜`#CD7F32`/白银`#9AA7B0`/黄金`#E5A83B`/铂金`#7B6BD6` | level 1-4 |

正文 16-18px、行高 1.8（阅读友好），圆角 20px 卡片，按钮胶囊 999。
**刻意不用股票软件大红大绿作主基调。**

## 5. 数据模型

### 5.1 本地存储（store/app.js 持久化到 uni.setStorage）
键 `cxch_progress`，结构与 Flutter `AppState` 对齐：
```json
{
  "total_points": 0, "current_level": 1, "rank_title": "青铜小白",
  "cards_read": { "C1_001": "mastered" }, "cards_read_count": 0,
  "quizzes_passed": [], "quiz_records": {},
  "sim_records": {}, "daily_streak": 0, "daily_last": "", "daily_done": [],
  "crash_sim_used": false, "onboarding_done": false,
  "risk_profile": null, "review_queue": [], "unlocked_fruits": []
}
```

### 5.2 云端（user_progress 集合，按 user_id）
与本地结构一致 + `updated_at`。登录后自动同步：本地 → 云端（debounce），云端 → 本地（拉取合并）。

### 5.3 章节解锁规则（移植 app_state.dart）
- C1 始终解锁（unlock_type=none）
- 其余 unlock_type=prev_chapter：上一章 `quizzes_passed` 含其 `unlock_ref` 才解锁
- 测验通过线：`required_correct_rate=0.8` 且答对数 ≥ `required_quiz_count=5`（8题里对5题即≥62.5%，实际用 correct/total≥0.8 判定 → 8题需对7题；保留与原版一致按 rate 判定）

> 核对原版：recordQuizAttempt 里 passed = correct/total ≥ required_correct_rate。8题需对 ceil(8*0.8)=7 题。保持一致。

## 6. 用户系统设计（核心）

### 6.1 登录方式
| 端 | 方式 | 实现 |
|---|---|---|
| 小程序 | 微信登录 | `uni.login`→code→云函数 `loginByWeixin` 换 openid→uni-id 发 token |
| 小程序 | 手机号一键 | `button open-type=getPhoneNumber`→云函数解密→绑定 |
| H5 | 微信网页授权 | 公众号 OAuth（需配置）→ `loginByWeixin` |
| 通用 | 游客模式 | 未登录用本地进度，登录后合并上云 |

### 6.2 鉴权
- uni-id-common 颁发 token，存 `uni.setStorage('uni_id_token')`
- 云对象 `before` 钩子校验 token，取 `uid`
- 进度云函数以 uid 隔离数据

### 6.3 进度同步策略（local-first）
1. 所有状态变更**先写本地**（即时反馈，离线可用）
2. **debounce 3s** 调云函数 `progress.save`（增量字段）
3. 登录/启动时 `progress.get` 拉云端，与本地按 `updated_at` 取新合并
4. 冲突策略：字段级，数值取较大（积分/连击），列表取并集（已读/已通关）

### 6.4 用户管理（管理系统）
- 基础：uni-id-users 集合存账号（openid/手机号/昵称/头像/注册时间）
- 管理后台：文档说明接入 **uni-admin**（官方后台框架，含用户列表/封禁/统计），无需自研

## 7. MVP 范围（V1）

**含：** 引导页 / 首页(段位+成长树+每日入口) / 学习(章节/滑卡/复习/闯关测验) / 模拟(复利+定投+通胀+模拟人生) / 风险测评 / 每日挑战 / 书架 / 我的 / **用户登录+进度云同步**。

**第二轮打磨：** 滑卡手势手感对齐、8模拟逐个打磨、成长树动效、真机适配。

## 8. 合规（过审关键）
- 类目报"教育-在线教育"，**不报金融理财**
- 文案去金融化（投资→财商认知/金钱管理，收益→示例数值）
- 免责声明前置：首次进入 + 工具结果页 + 关于页
- 全程无买入/卖出/代码/加群入口

## 9. 部署
1. HBuilderX 或 CLI `npm install` → `npm run dev:h5` / `build:mp-weixin`
2. uniCloud：关联阿里云服务空间，右键 cloudfunctions 上传部署，database 初始化
3. 小程序：微信开发者工具导入 dist，填 appid，提审（教育类目）
4. H5：上传到服务器/公众号文章嵌入
