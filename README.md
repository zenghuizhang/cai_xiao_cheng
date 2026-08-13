# 财小苗 · 投资认知启蒙 App（Android APK）

> 从零开始，慢慢变富。
> 一款为投资小白打造的**纯教育、纯离线**投资认知启蒙应用。

财小苗不荐股、不交易、不开户、不收集任何数据——它只想在你投入第一分钱之前，
帮你建立能「保命」的投资常识。

---

## ✨ 功能一览

- **🌱 学习路径**：7 章 34 节体系化课程，每节 3 分钟左右
  1. 理财先理脑（通胀、复利、钱的三个账户）
  2. 认清风险（风险/波动、能力圈）
  3. 常见工具（储蓄、债券、基金、股票、房产黄金保险、加密货币）
  4. 指数基金与定投（指数、定投微笑曲线）
  5. 资产配置（分散、股债、再平衡、四笔钱）
  6. 避开镰刀（保本高息骗局、杀猪盘、P2P、认知偏差）
  7. 开始行动（应急金、清坏债、开户、小步开始）
- **📝 小节测验**：每节 2–3 题，即时反馈，全对才能通过并解锁下一节
- **🧰 工具箱**：复利计算器、定投计算器、通胀缩水计算器、8 题风险承受力测评、40+ 术语词典
- **👤 我的**：学习统计、6 枚成就徽章、每日一签
- **🛡️ 隐私**：无网络权限、无账号、无第三方 SDK、飞行模式完全可用
- 首次启动 3 屏引导，全程暖色成长绿设计，小苗吉祥物陪伴

## 🔒 权限与隐私

`AndroidManifest.xml` 中**未声明任何权限**，包括 `INTERNET`。
应用内 WebView 同时启用 `setBlockNetworkLoads(true)` 双保险，
所有内容随 APK 内置，不发起、也无法发起任何网络请求。
学习进度仅保存在本机 `localStorage`，应用卸载即清除。

## 🏗 技术架构

- **原生外壳**：Java + 单 `Activity` + `WebView`（无任何第三方运行时依赖）
- **内容层**：原生 HTML/CSS/JS 单页应用（无框架、无构建步骤），置于 `app/src/main/assets/www/`
  - `js/data.js`：全部课程、测验、术语、格言内容
  - `js/store.js`：本地进度/成就/连续天数
  - `js/app.js`：路由、组件、SVG 图表、全部页面
- **构建**：Android Gradle Plugin 8.2.1 + Gradle 8.5 + JDK 17，`compileSdk 33 / minSdk 24`
- **安装包体积**：约 1–2 MB

## 🔨 构建

需要 JDK 17、Android SDK（platform 33、build-tools 33.0.2）。

```bash
cd android
# 本机已安装 gradle 8.5：
gradle :app:assembleDebug
# 或使用 wrapper（需自行生成 gradle wrapper）
```

产物路径：

```
android/app/build/outputs/apk/debug/app-debug.apk
```

### 安装到手机/模拟器

```bash
adb install -r android/app/build/outputs/apk/debug/app-debug.apk
```

也可直接把 APK 传到 Android 手机（Android 7.0+），允许「安装未知来源应用」后点击安装。

## 📁 目录结构

```
touzirenzhi/
├── docs/                     # 设计文档
│   ├── 01-设计prompt.md      # 设计 Prompt + 设计系统
│   ├── 02-产品定位.md
│   ├── 03-产品PRD.md
│   └── 04-项目拆解.md
├── android/                  # Android 工程
│   ├── settings.gradle / build.gradle / gradle.properties
│   └── app/
│       ├── build.gradle
│       └── src/main/
│           ├── AndroidManifest.xml
│           ├── java/com/caixiaomiao/app/MainActivity.java
│           ├── res/          # 主题、自适应图标（矢量）
│           └── assets/www/   # 前端 SPA
│               ├── index.html
│               ├── css/style.css
│               └── js/{data,store,app}.js
└── README.md
```

## ⚠️ 免责声明

本应用所有内容（课程、测验、计算器、风险测评、术语解释）**仅用于金融知识
普及与教育目的**，不构成任何投资建议、要约或承诺。文中收益率、比例等均为
教学示例，不代表对未来的预测。投资有风险，决策需谨慎；必要时请咨询持牌
专业机构。

## 📄 版本

v1.0
