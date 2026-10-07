#!/usr/bin/env bash
# hermes-evolution install.sh — one-shot setup di HOME SERVER (bukan di VPS Shania).
# Usage: ./install.sh
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "== Hermes Evolution Pack installer =="
echo "HERMES_HOME: $HERMES_HOME"

command -v hermes >/dev/null 2>&1 || { echo "ERROR: 'hermes' tidak ketemu di PATH. Install dulu: https://hermes-agent.nousresearch.com/"; exit 1; }

# 1. Update hermes-agent ke versi terbaru
echo ">> [1/5] Update hermes-agent..."
hermes update || echo "   (update gagal / sudah terbaru, lanjut)"

# 2. Pasang SOUL.md (backup dulu)
echo ">> [2/5] Pasang SOUL.md..."
mkdir -p "$HERMES_HOME"
[ -f "$HERMES_HOME/SOUL.md" ] && cp "$HERMES_HOME/SOUL.md" "$HERMES_HOME/SOUL.md.bak.$(date +%Y%m%d-%H%M%S)" && echo "   backup SOUL.md lama disimpan."
cp "$REPO_DIR/soul/SOUL.md" "$HERMES_HOME/SOUL.md"
echo "   SOUL.md baru terpasang."

# 3. Guardrails
echo ">> [3/5] Pasang guardrails..."
cp "$REPO_DIR/config/guardrails.yaml" "$HERMES_HOME/guardrails.yaml"
echo "   guardrails.yaml -> $HERMES_HOME/guardrails.yaml (edit sesuai selera)"

# 4. Daftarkan cron jobs
echo ">> [4/5] Daftarkan cron jobs..."
hermes cron create "daily at 23:30" "$(cat "$REPO_DIR/cron/daily-review.txt")" --name "evolution-daily-review" || echo "   (daily-review gagal didaftarkan, cek sintaks jadwal)"
hermes cron create "every 45m" "$(cat "$REPO_DIR/cron/heartbeat.txt")" --name "evolution-heartbeat" || echo "   (heartbeat gagal didaftarkan, cek sintaks jadwal)"
echo "   Cek: hermes cron list"

# 5. Learning loop bawaan — MERGE MANUAL (tidak otomatis, terlalu riskan nimpa config)
echo ">> [5/5] Learning loop bawaan (MANUAL):"
echo "   Merge isi config/learning.yaml ke $HERMES_HOME/config.yaml pakai editor."
echo "   Lihat docs/ENABLE-LEARNING.md buat penjelasan tiap key."

echo ""
echo "== SELESAI =="
echo "- SOUL.md aktif mulai sesi berikutnya."
echo "- Cron jobs jalan di gateway (hermes serve / gateway harus aktif + Telegram terkonfigurasi)."
echo "- Jangan lupa merge config/learning.yaml manual."
echo "- Test: hermes cron trigger evolution-heartbeat"
