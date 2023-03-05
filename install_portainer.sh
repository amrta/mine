#!/bin/bash

# 检测必要的依赖
if ! command -v curl > /dev/null || ! command -v docker > /dev/null || ! command -v docker-compose > /dev/null; then
    echo "缺少必要依赖"
    exit 1
fi

# 检测操作系统是否为 Ubuntu，添加 Docker 仓库
if [ "$(lsb_release -si)" != "Ubuntu" ]; then
    echo "该脚本仅支持 Ubuntu"
    exit 1
fi
OS_VERSION=$(lsb_release -sc)
DOCKER_VERSION="20.10.3"
curl -fsSL <https://download.docker.com/linux/ubuntu/gpg> | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(uname -m) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] <https://download.docker.com/linux/ubuntu> $OS_VERSION stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
sudo apt update
sudo apt install -y apt-transport-https ca-certificates gnupg lsb-release
sudo apt update
sudo apt install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io
sudo usermod -aG docker $USER

# 安装 Docker Compose
LATEST_VERSION=$(curl -Ls -o /dev/null -w %{url_effective} <https://github.com/docker/compose/releases/latest> | cut -d / -f 8)
sudo curl -L "<https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-$>(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 安装 Portainer
PORTAINER_VOLUME="portainer_data"
PORTAINER_ADMIN_PASSWORD="shunjian"
PORTAINER_ADMIN_USERNAME="will"
sudo docker volume create $PORTAINER_VOLUME
sudo docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v $PORTAINER_VOLUME:/data portainer/portainer-ce --admin-password $PORTAINER_ADMIN_PASSWORD --admin-username $PORTAINER_ADMIN_USERNAME

echo "安装完成！"
