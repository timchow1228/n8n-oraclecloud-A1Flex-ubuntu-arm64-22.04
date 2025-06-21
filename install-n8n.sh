#!/bin/bash

# 交互输入变量
read -p "请输入 n8n 登录用户名（USERNAME）： " USERNAME
read -s -p "请输入 n8n 登录密码（PASSWORD，输入时不可见）： " PASSWORD
echo
read -p "请输入域名（DOMAIN，比如 n8n.example.com）： " DOMAIN
read -p "请输入 Cloudflare Tunnel 名称（TUNNEL_NAME）： " TUNNEL_NAME

N8N_DIR=~/n8n-docker
DATA_DIR=$N8N_DIR/n8n_data

# 安装 Docker 和 Docker Compose
sudo apt update && sudo apt install -y docker.io docker-compose nano curl unzip

sudo systemctl enable docker && sudo systemctl start docker

# 创建目录并修复权限
mkdir -p $DATA_DIR
sudo chown -R 1000:1000 $DATA_DIR

# 写 Docker Compose 文件
mkdir -p $N8N_DIR
cat > $N8N_DIR/docker-compose.yml <<EOF
version: "3.8"
services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=${USERNAME}
      - N8N_BASIC_AUTH_PASSWORD="${PASSWORD}"
      - WEBHOOK_URL=https://${DOMAIN}/
    volumes:
      - ./n8n_data:/home/node/.n8n
EOF

# 启动 n8n
cd $N8N_DIR
docker-compose up -d

# 安装 cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64.deb
sudo dpkg -i cloudflared-linux-arm64.deb

echo "请登录 Cloudflare 账户以授权 cloudflared"
cloudflared tunnel login

# 创建 tunnel
cloudflared tunnel create $TUNNEL_NAME

# 获取 tunnel 凭证文件路径
CRED_FILE=$(ls /root/.cloudflared/*.json | head -n 1)

mkdir -p ~/.cloudflared
cat > ~/.cloudflared/config.yml <<EOF
tunnel: $TUNNEL_NAME
credentials-file: $CRED_FILE

ingress:
  - hostname: ${DOMAIN}
    service: http://localhost:5678
  - service: http_status:404
EOF

# 配置 systemd 服务
sudo tee /etc/systemd/system/cloudflared.service > /dev/null <<EOF
[Unit]
Description=Cloudflare Tunnel
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/cloudflared tunnel run $TUNNEL_NAME
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable cloudflared
sudo systemctl start cloudflared

echo -e "\n✅ 部署完成！请访问 https://${DOMAIN}"
