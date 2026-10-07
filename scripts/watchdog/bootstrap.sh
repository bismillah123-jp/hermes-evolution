#!/usr/bin/env bash
# bootstrap.sh — idempotent: pastikan hermes gateway terinstall sebagai systemd service dan jalan.
# Jalankan di HOME SERVER. Butuh sudo untuk tulis /etc/systemd/system.
set -euo pipefail

# === SESUAIKAN KALAU PERLU ===
SERVICE_NAME="hermes-gateway"
# Perintah yang menjalankan gateway. Default: hermes serve.
# Kalau setup Sir pakai perintah lain, ubah baris ini.
SERVICE_CMD="${HERMES_GATEWAY_CMD:-hermes serve}"
SERVICE_USER="${SUDO_USER:-$USER}"
# ==============================

UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}.service"

echo "== hermes-gateway bootstrap =="

if ! command -v hermes >/dev/null 2>&1; then
  echo "ERROR: 'hermes' tidak ada di PATH untuk user $SERVICE_USER. Install dulu."
  exit 1
fi

echo ">> Tulis unit $UNIT_PATH ..."
sudo tee "$UNIT_PATH" > /dev/null <<EOF
[Unit]
Description=Hermes Agent Gateway
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${SERVICE_USER}
Environment=HOME=/home/${SERVICE_USER}
Environment=HERMES_HOME=/home/${SERVICE_USER}/.hermes
ExecStart=/bin/bash -lc '${SERVICE_CMD}'
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME" >/dev/null
if ! sudo systemctl is-active --quiet "$SERVICE_NAME"; then
  echo ">> Service mati, start..."
  sudo systemctl start "$SERVICE_NAME"
else
  echo ">> Service sudah active."
fi

sudo systemctl is-active --quiet "$SERVICE_NAME" && echo "BOOTSTRAP_DONE" || { echo "GAGAL start"; exit 1; }
