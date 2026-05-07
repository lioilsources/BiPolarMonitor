#!/usr/bin/env bash
# Install and configure Cloudflare Tunnel for BipolarMonitor on DGX Spark (Ubuntu)
set -euo pipefail

# 1. Install cloudflared
curl -L --output cloudflared.deb \
  https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
sudo dpkg -i cloudflared.deb && rm cloudflared.deb

# 2. Authenticate (opens browser — run interactively once)
# cloudflared tunnel login

# 3. Create tunnel
# cloudflared tunnel create bipolar-monitor
# → saves credentials JSON to ~/.cloudflared/<TUNNEL_ID>.json

# 4. Copy credentials
# sudo mkdir -p /etc/cloudflared
# sudo cp ~/.cloudflared/<TUNNEL_ID>.json /etc/cloudflared/bipolar-creds.json
# sudo cp bipolar-tunnel.yml /etc/cloudflared/bipolar-tunnel.yml
# → Edit bipolar-tunnel.yml: replace <TUNNEL_ID> with actual ID

# 5. Add DNS route
# cloudflared tunnel route dns bipolar-monitor bipolar.ol1n.com

# 6. Install as systemd service
sudo cloudflared service install --config /etc/cloudflared/bipolar-tunnel.yml
sudo systemctl enable --now cloudflared

echo "Tunnel installed. Check: sudo systemctl status cloudflared"
