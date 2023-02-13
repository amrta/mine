echo '#!/bin/bash

# 停止 Cloudflare Warp
cloudflared tunnel stop

# 编辑 X-UI 配置文件
vi /etc/x-ui/x-ui.conf

# 更改 X-UI 端口
sed -i 's/listen = 0.0.0.0:54321/listen = 0.0.0.0:54322/g' /etc/x-ui/x-ui.conf

# 重启 X-UI
systemctl restart x-ui

# 重新启动 Cloudflare Warp
cloudflared tunnel start

echo "X-UI 端口已更改为 54322，Cloudflare Warp 重新启动完成"' > fix-x-ui-conflict.sh
