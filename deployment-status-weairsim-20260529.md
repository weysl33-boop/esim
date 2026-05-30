# WeAirSim 新版部署状态 - 2026-05-29

## 已完成

- 旧版 Node/PM2 WeAirSim 环境已清理。
- 新版 ViserLab Laravel Web 端已部署到服务器：
  - 站点目录：`/home/wwwroot/lnmp01/domain/weairsim.com`
  - PHP：`/usr/local/php-8.4`
  - PHP-FPM 配置：`/home/wwwroot/lnmp01/php-fpm/weairsim.com.conf`
  - Nginx 配置：`/home/wwwroot/lnmp01/vhost/weairsim.com-https.conf`
- 新建独立 MariaDB 10.11 服务：
  - 服务名：`weairsim-mariadb`
  - 监听：`127.0.0.1:3307`
  - 数据目录：`/home/usrdata/weairsim-mariadb`
  - 数据库：`weairsim`
  - 数据表导入数量：39
- Laravel `.env` 已生成并写入服务器：
  - `APP_URL=https://www.weairsim.com`
  - `APP_ENV=production`
  - 数据库连接到独立 MariaDB 10.11
- 管理员账号已设置：
  - 后台地址：`https://www.weairsim.com/admin`
  - 用户名：`admin`
  - 邮箱：`mail@weairsim.com`
  - 密码：使用部署时已授权的同一密码，未写入本文件
- Web 基础设置已改为：
  - 站点名：`WeAirSim`
  - 币种：`USD`
  - 发信邮箱：`mail@weairsim.com`
- 手机端 Flutter API 地址已改为：
  - 文件：`Z:\appS\esim\esim-cross-platform-mobile-app-for-international-esim-and-data-purchase\Files\lib\core\utils\url_container.dart`
  - `domainUrl=https://www.weairsim.com`

## 当前阻塞

新版源码已运行，但 ViserLab 授权未激活，所有前台、后台、API 请求都会跳转到：

`https://www.weairsim.com/activate`

激活页需要：

- Envato / CodeCanyon Purchase Code
- Envato Username
- Purchase Email

未完成激活前，后台登录和移动端 API 不能正式使用。

## 激活后下一步

- 已验证后台登录。
- 已迁移 Airalo sandbox 凭证，并验证 token endpoint 成功。
- 已迁移 eSIM Access 凭证，当前保持禁用。
- 已保留 eSIM Go 密钥到服务器 `.env`，但新版源码没有 eSIM Go 模块，不能在后台直接启用。
- 已配置 Stripe Checkout 和 PayPal Express，并关闭演示支付网关。
- 已配置腾讯企业邮箱 SMTP，服务器到 `smtp.exmail.qq.com:465` 连通。
- 已配置 Firebase Web 配置。
- 同步套餐计划并测试下单流程。
- 构建 Android 客户端并验证 API 登录、注册、套餐、订单接口。

## 当前保留事项

- Google 社交登录需要 Google OAuth `client_id` 和 `client_secret`。当前密钥清单只有 Firebase Web 配置，没有单独 OAuth Client Secret，因此未强行写入 Socialite 登录。
- Airalo 当前按原清单的 sandbox 凭证配置，正式销售前需要确认 Airalo production/billing 审核完成。
- 生产销售前需要先同步国家/地区/套餐，再做低价闭环测试。
