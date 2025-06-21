n8n完整一键安装脚本（适配 Cloudflare Tunnel + ARM + 权限修复）
适配 ARM 架构 + Docker Compose + Cloudflare Tunnel

准备工作：
1.域名必须已添加到 Cloudflare 并处于激活状态，n8n的访问域名，比如n8n.xx.xxx，IP地址要指向VPS服务器。
2.在 Cloudflare 控制面板的 DNS 设置里，暂时可以不添加任何关于域名n8n.xx.xxx的记录，脚本会自动使用 Cloudflare Tunnel 动态创建对应的子域名指向隧道，也可以先预留一个 CNAME 记录（如 n8n）指向任意地址，后续脚本运行完成后你再修改为隧道生成的 UUID.cfargotunnel.com。
3.脚本中会自动安装 cloudflared，但你要提前准备好 Cloudflare 账户登录信息，方便运行 cloudflared tunnel login 时扫码或网页登录授权。运行脚本时会跳出浏览器窗口，要求你登录并授权 cloudflared 访问你的 Cloudflare 账户。
4.虽然 cloudflared 隧道不会直接暴露端口，但你本地的 n8n 仍监听在 5678 端口。确保服务器的防火墙允许本地回环和 Docker 容器端口转发。

使用方法
1.下载或以上内容，保存为 install-n8n.sh
2.执行：
chmod +x install-n8n.sh
./install-n8n.sh
3.搞定，访问n8n.xx.xxx即可




