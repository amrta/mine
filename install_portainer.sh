#!/bin/bash

# 检查必要依赖是否已经安装
for cmd in "curl" "docker" "docker-compose"; do
    command -v "$cmd" &> /dev/null || { echo "缺少必要依赖 $cmd"; exit 1; }
done

# 检测 CPU 架构和 Ubuntu 系统版本
CPU_ARCH="$(uname -m)"
case "$CPU_ARCH" in
    x86_64) ;;
    aarch64) ;;
    *)
        echo "不支持的 CPU 架构：$CPU_ARCH"
        exit 1
        ;;
esac
OS_VERSION="$(. /etc/os-release && echo "$VERSION_ID")"
if [ -z "$OS_VERSION" ]; then
    echo "无法检测到系统版本号"
    exit 1
fi

# 卸载 Docker 和 Docker Compose
echo "卸载 Docker 和 Docker Compose..."
sudo apt-get remove -y docker docker-engine docker.io containerd runc
sudo rm -rf /var/lib/docker /etc/docker /etc/systemd/system/docker.service.d /usr/share/keyrings/docker-archive-keyring.gpg /usr/share/keyrings/docker-archive-ubuntu-keyring.gpg /usr/bin/docker-compose /usr/local/bin/docker-compose /usr/local/bin/docker-compose-Linux-arm64

# 安装 Docker
echo "安装 Docker..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$CPU_ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $OS_VERSION stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker "$USER"

# 安装 Docker Compose
echo "安装 Docker Compose..."
LATEST_VERSION="$(curl -Ls https://api.github.com/repos/docker/compose/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')"
sudo curl -L "https://github.com/docker/compose/releases/download/$LATEST_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 安装 Portainer
echo "安装 Portainer..."
sudo docker volume create portainer_data
sudo docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce --admin-password shunjian --admin-username will

echo "安装完成！"
