# 财小橙 · 鸿蒙版（HarmonyOS NEXT）

> 🚧 **状态：规划中，尚未开始编码。**
>
> 本目录为鸿蒙原生版本预留。当前财小橙已落地 Flutter 版（`../flutter`）与小程序/H5 版（`../miniprogram`），后端用户系统在 `../backend`。鸿蒙版将作为第三客户端形态，复用同一套产品内容与后端。

---

## 为什么做鸿蒙版

- HarmonyOS NEXT（纯血鸿蒙）已不再兼容 Android APK，Flutter 版无法直接在鸿蒙原生环境分发。
- 鸿蒙生态设备量增长，原生 ArkTS 应用可上架华为应用市场，触达增量用户。
- 与小程序版互补：小程序覆盖微信生态，鸿蒙版覆盖华为设备生态。

## 技术路线（规划）

| 项 | 选型 |
|---|---|
| 语言 | ArkTS |
| 框架 | HarmonyOS NEXT / ArkUI（声明式 UI） |
| 工具链 | DevEco Studio + HarmonyOS SDK |
| 状态管理 | ArkUI 内置状态（@State / @Observed / AppStorage） |
| 本地存储 | @ohos.data.preferences / 关系型数据库 relationalStore |
| 网络/云同步 | 复用 `../backend` 的 uniCloud HTTP 接口（uniCloud 提供 URL 化云函数，可被非 uni-app 客户端调用） |
| 内容 | 复用 `../miniprogram/src/data/knowledge_base.json`（同一份内容源） |

## 后端复用说明

鸿蒙版**不另起后端**，直接复用 `../backend` 的 uniCloud 云函数：

- uniCloud 支持把云函数 **URL 化**（控制台 → 云函数 → 详情 → 云函数URL化），生成 HTTPS 端点。
- ArkTS 通过 `@ohos.net.http` 以标准 HTTP POST 调用 `user-center`，请求体 `{ action, params }`，与小程序版 `uniCloud.callFunction` 等价。
- 登录态：uni-id 返回的 token 自行存入 preferences，后续请求带 `uni-id-token` 头。

> 即：鸿蒙版只需实现 ArkTS 客户端 + 一个薄薄的 HTTP 封装层，业务逻辑与数据结构与小程版 `store/user.js` 一一对应。

## 启动步骤（待执行）

1. 安装 [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/) 与 HarmonyOS NEXT SDK。
2. 本目录 `harmonyos/` 下用 DevEco 新建 ArkTS 工程（Empty Ability）。
3. 移植设计 token（暖橙主题，见 `../miniprogram/src/uni.scss`）为 ArkUI 样式。
4. 按 `../docs/03-产品PRD.md` 逐页实现：引导 → 学习滑卡 → 闯关 → 模拟器 → 书架 → 风险测评 → 我的。
5. 接入 `../backend` 的 URL 化云函数，实现登录与进度同步。
6. 用 HarmonyOS 模拟器 / 真机调试，最终上架华为应用市场。

## 内容复用

鸿蒙版的章节/卡片/题目/书架/术语全部来自 `../miniprogram/src/data/knowledge_base.json`——这是三端共享的单一内容源。建议鸿蒙版构建时拷贝或软链该 JSON，避免内容分叉。

---

> 本目录当前为空（仅本 README）。开始编码时按上方「启动步骤」建立 ArkTS 工程结构。
