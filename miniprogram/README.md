# 财小橙 · uni-app 版

> 投资认知启蒙 · 纯教育、零交易。一套 Vue3 代码同时编译出**微信小程序**与 **H5**，并内置完整用户系统（登录 + 学习进度云同步）。

由 Flutter 离线版重写而来，配合「个人影响力」路线：小程序作轻量分发入口，H5 可嵌公众号落地页。

---

## ✅ 当前状态（v1.0 MVP）

- 20 个页面全部实现，**mp-weixin 与 H5 双端构建通过** ✅
- MVP 核心闭环完整：引导 → 滑卡学习 → 闯关测验 → 复习 → 每日 → 模拟人生 → 计算器 → 书架 → 风险测评 → 暴跌演练
- 用户系统：微信登录 / 手机号一键登录 / 短信验证码登录 + 进度云端同步 + uni-admin 管理（云函数已就绪，部署见下）
- 本地优先：未登录可完整使用（游客模式），登录后跨设备同步

---

## 🛠 技术栈

| 层 | 选型 |
|---|---|
| 框架 | uni-app **Vue3 + Vite** |
| 状态 | Pinia（options API） |
| 后端 | uniCloud（阿里云）+ uni-id-common |
| 样式 | SCSS + uni.scss 设计 token（暖橙 #FF8C42） |
| 内容 | knowledge_base.json（从 Flutter 原样复用） |

---

## 🚀 快速开始

```bash
# 1. 安装依赖
npm install

# 2. 开发
npm run dev:mp-weixin     # 微信小程序：用「微信开发者工具」导入 dist/dev/mp-weixin
npm run dev:h5            # H5：访问 http://localhost:8080

# 3. 构建
npm run build:mp-weixin   # 产物 dist/build/mp-weixin
npm run build:h5          # 产物 dist/build/h5
```

> 依赖版本已锁定为 `@dcloudio/*@3.0.0-5020420260813002`（vue3 tag，2026-08-13 构建），所有 dcloudio 包须同版本。

### 运行小程序

1. `npm run build:mp-weixin`
2. 打开**微信开发者工具** → 导入项目 → 目录选 `dist/build/mp-weixin`
3. 填入你的小程序 AppID（`src/manifest.json` → `mp-weixin.appid`）

### 运行 H5

`npm run dev:h5` 本地预览；`npm run build:h5` 后将 `dist/build/h5` 部署到任意静态托管 / uniCloud 前端网页托管。

---

## 📦 工程结构

```
miniprogram/                       # 本目录（uni-app 前端工程）
├── src/
│   ├── App.vue                 # onLaunch：初始化 store、引导页判断
│   ├── main.js                 # createSSRApp + Pinia
│   ├── pages.json              # 20 页路由 + 4 tab + globalStyle
│   ├── manifest.json           # 小程序 AppID / uniCloud 服务空间 / H5
│   ├── uni.scss                # 设计 token（暖橙主题）
│   ├── data/knowledge_base.json
│   ├── components/             # SwipeCard / GlossarySheet / OrangeMascot / PageHeader / ...
│   ├── pages/                  # home learn simulation mine onboarding login risk daily books
│   ├── store/                  # app.js(进度) + user.js(登录/同步)
│   └── utils/                  # storage content finance format
├── docs/DESIGN.md              # 架构设计文档
└── README.md                   # 本文件

# 后端（uniCloud 云函数 + 数据库）已抽离到仓库根的 ../backend/，见其 README
```

---

## 🔐 用户系统部署（3 步）

完整步骤见 [`../backend/README.md`](../backend/README.md)，精简版：

1. **关联服务空间**：uniCloud 控制台创建阿里云空间，把 `spaceId/clientSecret/endpoint` 填入 `src/manifest.json` 的 `mp-weixin.uniCloud` 与 `h5.uniCloud`。
2. **部署后端**：HBuilderX 打开 `../backend` → 安装公共模块 `uni-id-common` + `uni-config-center` → 填 `uni-id/config.json`（替换密钥、微信 AppID/Secret）→ 上传 `user-center` 云函数与 `cxch-user-progress` schema。
3. **（可选）uni-admin**：新建 uni-admin 项目关联同一空间，即可后台管理登录用户。

> 未配置时 App 自动降级为本地游客模式，不崩溃。

---

## 🧭 核心功能

- **学习闭环**：4 章 × 滑卡知识 → 闯关测验（≥80% 通关，首通解锁果实/升段）→ 复习队列（艾宾浩斯式）→ 每日 3 分钟
- **模拟器**：复利 / 定投 / 通胀缩水 三大计算器（slider 交互）+ 模拟人生历史场景
- **认知工具**：风险承受力测评（5 题→画像+配置建议）、暴跌演练（6 天情绪沙盘）
- **书架**：16 本经典投资书大白话导读（核心思想/一句话带走/阅读路径）
- **段位体系**：青铜→白银→黄金→铂金，认知积分 + 虚拟本金激励
- **用户系统**：微信/手机号登录 + 进度云同步（数值取大、列表取并集，多端不覆盖）

---

## ⚖️ 合规定位

- 类目「教育-在线教育」，**绝不做金融类目**
- 全程去金融化措辞，不荐股/不预测/不承诺收益/无买卖/无群码入口
- 醒目免责声明（getDisclaimer）贯穿计算器、模拟、书架、关于页
- 所有收益率为假设性教学案例

---

## 📚 文档

- 架构设计：[`docs/DESIGN.md`](./docs/DESIGN.md)
- 后端部署：[`../backend/README.md`](../backend/README.md)

---

## 📝 版本

- **v1.0**（2026-08-15）：uni-app 版首发，MVP 核心闭环 + 用户系统，双端构建通过。
