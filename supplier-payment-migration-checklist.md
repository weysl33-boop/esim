# WeAirSim 供应商与支付网关迁移清单

更新日期：2026-05-28

## 邮件/供应商接入状态

- Airalo 申请已批准。Mina Mizukoshi 于 2026-05-27 回复确认 application approved。
- Airalo onboarding 邮件已到达 `mail@weairsim.com`，并转发到 Gmail。
- Airalo Partner Platform 账号：`mail@weairsim.com`。
- Airalo 当前仍是 provisional / verification 流程，切生产前需要确认 Airalo billing/legal 审核完成。
- 当前服务器已配置 Airalo sandbox API，且此前已验证 token 和套餐读取接口可用。
- 当前生产供应商仍应保持 `eSIM Go`，不要在 Airalo 生产审核完成前切换主供应商。

## 完整密钥文件

- 完整密钥清单在本地私密文件：`analysis/weairsim-secrets-inventory.local.md`
- 脱敏查看版：`analysis/weairsim-secrets-inventory-redacted.md`
- 这两个文件已被 `.gitignore` 排除，不要上传 GitHub / Codex 云端 / 公共网盘。

## 供应商变量迁移

新源码需要支持或保留以下环境变量：

- `AIRALO_API_KEY`
- `AIRALO_API_SECRET`
- `AIRALO_ENV`
- `ESIM_ACCESS_CLIENT_ID`
- `ESIM_ACCESS_CLIENT_SECRET`
- `ESIM_GO_API_KEY`
- `MAYA_API_KEY`
- `MAYA_API_SECRET`
- `DATAPLANS_API_KEY`（源码支持，但当前服务器未确认有值）

供应商数据库状态需要迁移：

- `providers.airalo`: 当前不启用；用于 sandbox 验证。
- `providers.esim-go`: 当前启用；继续作为生产供应商。
- `providers.esim-access`: 当前不启用。
- `providers.maya`: 当前不启用。
- `providers.data-plans`: 当前不启用。

## 支付网关变量迁移

服务器 `.env` / 数据库中需要重点迁移：

- Stripe:
  - `STRIPE_SECRET_KEY`
  - `VITE_STRIPE_PUBLIC_KEY`
  - `STRIPE_WEBHOOK_SECRET`（当前需确认是否为空）
- PayPal:
  - 数据库 `payment_gateways.paypal.publicKey`
  - 数据库 `payment_gateways.paypal.secretKey`
  - 数据库 `payment_gateways.paypal.config`
- Razorpay:
  - `RAZORPAY_KEY_ID`
  - `RAZORPAY_KEY_SECRET`
- Alipay:
  - `ALIPAY_APP_ID`
  - `ALIPAY_PRIVATE_KEY`
  - `ALIPAY_PUBLIC_KEY`
  - `ALIPAY_GATEWAY_URL`
  - `ALIPAY_RETURN_URL`
  - `ALIPAY_NOTIFY_URL`
- 预留/本地模板项：
  - `WECHAT_MCH_ID`
  - `WECHAT_API_KEY`
  - `WECHAT_APP_ID`
  - `LINEPAY_CHANNEL_ID`
  - `LINEPAY_CHANNEL_SECRET`
  - `GRABPAY_CLIENT_ID`
  - `GRABPAY_CLIENT_SECRET`
  - `PAYSTACK_SECRET_KEY`
  - `POWERTRANZ_*`

## 邮箱与平台配置迁移

- SMTP 当前使用腾讯企业邮箱：
  - `SMTP_HOST`
  - `SMTP_PORT`
  - `SMTP_USER`
  - `SMTP_PASS`
  - 数据库 `settings.smtp_*`
- Firebase/Google 登录需要迁移：
  - `firebase_api_key`
  - `firebase_auth_domain`
  - `firebase_project_id`
  - `firebase_storage_bucket`
  - `firebase_messaging_sender_id`
  - `firebase_app_id`
  - `firebase_measurement_id`
  - `GOOGLE_SERVICE_ACCOUNT_PATH`
- 会话安全：
  - `SESSION_SECRET`
  - `JWT_SECRET`

## 切换源码前检查顺序

1. 新源码先不要接真实支付和真实供应商下单，只部署到测试路径或临时域名。
2. 导入 `.env` 必需变量，先验证服务器启动、登录、SMTP。
3. 验证 Firebase Google 登录。
4. 验证 Stripe/PayPal 测试支付配置，不要先开真实支付。
5. 验证 eSIM Go 查询/下单测试逻辑，但不要做真实订单，除非明确准备做低价闭环测试。
6. 验证 Airalo sandbox token 和套餐读取。
7. 等 Airalo production/billing 审核完成后，再切 `AIRALO_ENV=production`。
8. 最后切供应商优先级：Airalo 可启用，eSIM Go 保留 fallback。

## 不能遗漏的风险

- 不要把 `analysis/weairsim-secrets-inventory.local.md` 上传。
- 不要把 service account JSON 上传。
- 不要把 Airalo sandbox 直接用于前台真实销售。
- 不要只迁移 `.env`，支付网关和 SMTP 有一部分配置在数据库表中。
