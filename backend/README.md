# 财小橙 · uniCloud 用户系统部署指南

本目录是 uniCloud（阿里云）后端，承载**用户系统**：微信/手机号登录 + 学习进度云端同步 + uni-admin 管理。

> 纯教育定位：本后端仅同步**学习进度**，不处理任何交易、资金、金融数据。
>
> 本目录与前端解耦：云函数/云对象源码独立部署到服务空间，前端（`../miniprogram`）只通过 `manifest.json` 里的 `spaceId` 调用，构建时不依赖本目录。

## 架构分工

| 组件 | 类型 | 职责 |
|------|------|------|
| **uni-id-co** | 云对象（官方） | 登录/登出/短信验证码/账号管理（`loginByWeixin`、`loginByWeixinMobile`、`sendSmsCode`、`loginBySms`、`logout`、`getAccountInfo`） |
| **user-center** | 云函数（自建） | 学习进度存取（`saveProgress`、`getProgress`），内部用 `uni-id-common.checkToken` 鉴权 |
| **uni-id-common** | 公共模块 | token 校验/生成（`checkToken`、`createToken`） |
| **uni-config-center** | 公共模块 | uni-id 配置读取（`uni-id/config.json`） |

前端调用方式：
- 登录相关 → `uniCloud.importObject('uni-id-co')` 调用云对象
- 进度同步 → `uniCloud.callFunction({ name: 'user-center' })`

## 目录结构

```
backend/                             ← 本目录（独立的后端工程）
├── cloudfunctions/
│   ├── user-center/              ← 自建云函数：学习进度存取
│   │   ├── index.js
│   │   └── package.json
│   └── common/                   ← 公共模块（需自行下载，见下文）
│       ├── uni-id-common/
│       └── uni-config-center/
│           └── uni-id/config.json   ← uni-id 配置（需填密钥）
├── database/
│   └── cxch-user-progress.schema.json  ← 学习进度表结构 + 权限
└── README.md                        ← 本文件

# uni-id-co 云对象需通过 HBuilderX 从插件市场导入（见第三节）
```

---

## 一、前置准备

1. 注册 [uniCloud 控制台](https://unicloud.dcloud.net.cn/)，创建一个**阿里云**服务空间。
2. 记下服务空间的 `spaceId`、`clientSecret`、`endpoint`（控制台 → 服务空间详情）。

---

## 二、关联服务空间到前端

编辑前端工程的 `../miniprogram/src/manifest.json`，把 `mp-weixin.uniCloud` 与 `h5.uniCloud` 三处空值填上：

```jsonc
"uniCloud": {
  "provider": "aliyun",
  "spaceId": "你的 spaceId",
  "clientSecret": "你的 clientSecret",
  "endpoint": "https://api.next.bspapp.com"   // 阿里云一般为该地址
}
```

> 留空时，前端 `user.js` 的 `_call` 会进入 catch 分支，App 以**纯本地游客模式**运行——不会崩溃，登录入口会显示「云端服务暂未连接」。

---

## 三、安装公共模块与云对象

需要安装 **2 个公共模块** + **1 个云对象**。用 **HBuilderX** 打开本 `backend/` 目录：

### 3.1 公共模块（uni-id-common、uni-config-center）

1. 右键 `cloudfunctions` → **管理公共模块依赖** → 勾选 `uni-id-common`、`uni-config-center`。
2. 或到 [DCloud 插件市场](https://ext.dcloud.net.cn/) 搜索下载到 `cloudfunctions/common/` 下。

安装后：
```
cloudfunctions/common/uni-id-common/        (含 index.js)
cloudfunctions/common/uni-config-center/    (含 index.js + uni-id/ 目录)
```

### 3.2 云对象 uni-id-co（登录/登出/短信）

1. 右键 `cloudfunctions` → **新建云对象** → 选择从插件市场导入 `uni-id-co`。
2. 或插件市场搜索 `uni-id-co` 下载到 `cloudfunctions/uni-id-co/`。

`uni-id-co` 是官方封装好的账号云对象，提供 `loginByWeixin`、`loginByWeixinMobile`、`sendSmsCode`、`loginBySms`、`logout`、`getAccountInfo` 等方法，前端直接 `uniCloud.importObject('uni-id-co')` 调用。

---

## 四、填写 uni-id 配置

编辑 `cloudfunctions/common/uni-config-center/uni-id/config.json`（不存在则复制同目录 `config.example.json` 为 `config.json`）：

| 字段 | 说明 |
|------|------|
| `passwordSecret` / `tokenSecret` | **务必替换**为随机字符串（≥32 位）。可用 `openssl rand -hex 32` 生成。 |
| `mp-weixin.oauth.weixin.appid` / `appsecret` | 微信小程序后台获取，用于 `loginByWeixin` 与 `loginByPhone`。 |
| `service.sms.smsKey` / `smsSecret` | uni-ic 短信服务密钥（见第六节）。 |

---

## 五、部署云函数、云对象与数据库

1. 右键 `cloudfunctions/uni-id-co` → **上传部署**（云对象）。
2. 右键 `cloudfunctions/user-center` → **上传部署**（云函数）。
3. 右键 `database/cxch-user-progress.schema.json` → **上传 DB Schema**。
4. `uni-id-users` 表的 schema 会随 `uni-id-co` 自动带出，无需手写。

---

## 六、开通短信服务（H5 / 通用登录用）

微信小程序登录不需要短信。若要支持 H5 短信验证码登录：

1. uniCloud 控制台 → **短信服务（uni-ic）** → 开通。
2. 申请短信签名（如「财小橙」）与验证码模板，等待审核。
3. 拿到 `smsKey` / `smsSecret`，填入第四节 `config.json` 的 `service.sms`。
4. 模板内容需为验证码类型；uni-id `sendSmsCode` 默认 `scene: 'login-by-sms'`。

---

## 七、uni-admin 用户管理后台（可选但推荐）

用户希望用后台管理登录用户。uni-admin 是 DCloud 官方 admin 模板：

1. [插件市场下载 uni-admin](https://ext.dcloud.net.cn/plugin?id=3267)，用 HBuilderX 新建一个 uni-admin 项目。
2. 关联到**同一个** uniCloud 服务空间（与本项目一致）。
3. 部署后即可在后台「用户管理」中查看所有通过 `uni-id-co` 注册的 `uni-id-users` 用户。
4. 由于登录用户都写入 `uni-id-users` 表，uni-admin 可直接增删改查、封禁、改昵称等。

> 进度表 `cxch-user-progress` 也可在 uni-admin 的 DB Schema 管理里直接查看（仅本人可读写的权限不影响管理员）。

---

## 八、联调验证清单

- [ ] `../miniprogram/src/manifest.json` 三处 uniCloud 配置已填。
- [ ] `uni-id/config.json` 密钥已替换、微信 appid/secret 已填。
- [ ] `uni-id-co` 云对象 + `user-center` 云函数已上传部署；`cxch-user-progress` schema 已上传。
- [ ] 微信开发者工具中：我的 → 登录 → 微信一键登录，成功后「我的」显示昵称。
- [ ] 学习一张卡片 → 等 3s → 换设备登录同账号 → 进度已同步。
- [ ] 退出登录后本地进度保留、再登录可拉回。
- [ ] （可选）短信登录：H5 端输入手机号 + 图形验证码 + 短信验证码登录成功。

---

## 九、降级与容错

- 未填 spaceId / 云函数未部署：前端自动降级为本地游客模式，登录页提示「云端服务暂未连接」。
- 云端同步失败：`user.js` 的 `_markCloudUnavailable` 识别后静默，不影响本地学习。
- 合并策略（前端 `mergeProgress`）：数值取大、列表取并集、记录 passed 优先 / 时间取新，确保多端互不覆盖。

---

## 安全提醒

- `config.json` 中的密钥**不要提交到公开仓库**。仓库仅提交了 `config.example.json` 模板，真实 `config.json` 已加入 `.gitignore`。
- 进度表权限已设为「仅本人读写」，管理员通过 uni-admin 越权管理不受影响。
- 本应用不收集除学习记录与登录凭证外的任何信息，符合隐私合规。
