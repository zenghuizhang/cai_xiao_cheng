# 财小橙 · 投资认知启蒙（多端 monorepo）

> 从零开始，慢慢变富。
> 一款为投资小白打造的**纯教育、零交易**投资认知启蒙应用——不荐股、不交易、不开户、不预测收益。

本仓库按**客户端形态**归类为独立目录，共享同一套产品内容与设计语言，各自独立开发与构建。

---

## 📁 目录结构

```
cai_xiao_cheng/
├── flutter/        # Flutter 版（Android/iOS 原生 App，旗舰作品）
├── miniprogram/    # 小程序版（uni-app，一套代码出微信小程序 + H5）
├── harmonyos/      # 鸿蒙版（规划中，ArkTS / HarmonyOS NEXT）
├── backend/        # 后台（uniCloud 云函数 + 数据库，用户系统，各端共用）
├── docs/           # 共享产品文档（定位 / PRD / 项目拆解 / 内容框架）
└── README.md       # 本文件
```

| 目录 | 形态 | 技术栈 | 状态 |
|------|------|--------|------|
| `flutter/` | Android / iOS App | Flutter + Dart + Provider + SQLite | ✅ v2.0 可构建（`flutter build apk`） |
| `miniprogram/` | 微信小程序 + H5 | uni-app Vue3 + Vite + Pinia | ✅ v1.0 双端构建通过 |
| `harmonyos/` | 鸿蒙 HarmonyOS NEXT | ArkTS（规划） | 🚧 规划中，见其 README |
| `backend/` | uniCloud 服务端 | uniCloud（阿里云）+ uni-id | ✅ 云函数就绪，待部署 |

> 各端共享 `docs/` 下的产品文档与内容框架；后端 `backend/` 为所有客户端共用。

---

## 🍊 各端快速入口

### Flutter 版（`flutter/`）
```bash
cd flutter
flutter pub get
flutter build apk --release   # 产物 build/app/outputs/flutter-apk/app-release.apk
```
详见 [`flutter/README.md`](./flutter/README.md)。

### 小程序 / H5 版（`miniprogram/`）
```bash
cd miniprogram
npm install
npm run build:mp-weixin   # 产物 dist/build/mp-weixin，用微信开发者工具导入
npm run build:h5          # 产物 dist/build/h5
```
详见 [`miniprogram/README.md`](./miniprogram/README.md)。

### 后台（`backend/`）
uniCloud 云函数 + 数据库，承载用户系统（微信/手机号登录 + 进度云同步 + uni-admin 管理）。
部署步骤见 [`backend/README.md`](./backend/README.md)。

### 鸿蒙版（`harmonyos/`）
规划中，技术路线与启动步骤见 [`harmonyos/README.md`](./harmonyos/README.md)。

---

## 🧭 产品定位

- **纯教育、零交易**：类目「教育-在线教育」，绝不做金融类目；不荐股/不预测/不承诺收益/无买卖/无群码入口。
- **投资认知地基**：用大白话和生活类比，帮小白在投入第一分钱前建立能「保命」的常识——通胀、复利、风险、工具、骗局、情绪。
- **醒目免责**：所有收益率/历史场景/虚拟资产均为假设性教学案例，不构成投资建议。
- 隐私优先：默认本地存储，登录仅用于跨设备进度同步。

详见 [`docs/02-产品定位.md`](./docs/02-产品定位.md) 与 [`docs/03-产品PRD.md`](./docs/03-产品PRD.md)。

---

## 📚 共享文档

- [`docs/01-设计prompt.md`](./docs/01-设计prompt.md) — 设计语言
- [`docs/02-产品定位.md`](./docs/02-产品定位.md) — 定位与商业化决策
- [`docs/03-产品PRD.md`](./docs/03-产品PRD.md) — 产品需求文档
- [`docs/04-项目拆解.md`](./docs/04-项目拆解.md) — 项目拆解
- [`docs/词条与卡片扩充框架.md`](./docs/词条与卡片扩充框架.md) — 内容框架

---

## 📝 版本

- **v1.0**（2026-08-15）：monorepo 归类，flutter / miniprogram / backend 三端就绪，harmonyos 规划中。
