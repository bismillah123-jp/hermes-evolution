#!/usr/bin/env bash
# hermes-evolution install.sh — one-shot setup di HOME SERVER (bukan di VPS Shania).
# Usage: ./install.sh
set -euo pipefail

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "== Hermes Evolution Pack installer =="
echo "HERMES_HOME: $HERMES_HOME"

command -v hermes >/dev/null 2>&1 || { echo "ERROR: 'hermes' tidak ketemu di PATH. Install dulu: https://hermes-agent.nousresearch.com/"; exit 1; }

# 1. Update hermes-agent ke versi terbaru
echo ">> [1/7] Update hermes-agent..."
hermes update || echo "   (update gagal / sudah terbaru, lanjut)"

# 2. Pasang SOUL.md (backup dulu)
echo ">> [2/7] Pasang SOUL.md..."
mkdir -p "$HERMES_HOME"
[ -f "$HERMES_HOME/SOUL.md" ] && cp "$HERMES_HOME/SOUL.md" "$HERMES_HOME/SOUL.md.bak.$(date +%Y%m%d-%H%M%S)" && echo "   backup SOUL.md lama disimpan."
cp "$REPO_DIR/soul/SOUL.md" "$HERMES_HOME/SOUL.md"
echo "   SOUL.md baru terpasang."

# 3. Guardrails + goals + USER.md (timpa semua, backup dulu)
echo ">> [3/7] Pasang guardrails + goals + USER.md (overwrite)..."
cp "$REPO_DIR/config/guardrails.yaml" "$HERMES_HOME/guardrails.yaml"
for f in goals.yaml USER.md; do
  src=""; dst="";
  case "$f" in
    goals.yaml) src="$REPO_DIR/config/goals.yaml"; dst="$HERMES_HOME/goals.yaml" ;;
    USER.md)    src="$REPO_DIR/user/USER.md";      dst="$HERMES_HOME/USER.md" ;;
  esac
  [ -f "$dst" ] && cp "$dst" "$dst.bak.$(date +%Y%m%d-%H%M%S)" && echo "   backup $f lama disimpan."
  cp "$src" "$dst"
done
echo "   guardrails.yaml + goals.yaml + USER.md terpasang (ditimpasemua)"

# 4. Skill pack
echo ">> [4/7] Pasang skill pack..."
mkdir -p "$HERMES_HOME/skills"
for s in taskrelay stack-health affiliate-pipeline; do
  rm -rf "$HERMES_HOME/skills/$s"
  cp -r "$REPO_DIR/skills/$s" "$HERMES_HOME/skills/$s"
  echo "   skill: $s"
done

# 5. Daftarkan cron jobs
echo ">> [5/7] Daftarkan cron jobs..."
hermes cron create "daily at 23:30" "$(cat "$REPO_DIR/cron/daily-review.txt")" --name "evolution-daily-review" || echo "   (daily-review gagal, cek sintaks jadwal)"
hermes cron create "every 30m" "$(cat "$REPO_DIR/cron/heartbeat.txt")" --name "evolution-heartbeat" || echo "   (heartbeat gagal, cek sintaks jadwal)"
hermes cron create "daily at 07:00" "$(cat "$REPO_DIR/cron/morning-briefing.txt")" --name "evolution-morning-briefing" || echo "   (morning-briefing gagal, cek sintaks jadwal)"
hermes cron create "weekly on sunday at 20:00" "$(cat "$REPO_DIR/cron/weekly-review.txt")" --name "evolution-weekly-review" || echo "   (weekly-review gagal, cek sintaks jadwal — coba 'every 7d')"
hermes cron create "every 30d" "$(cat "$REPO_DIR/cron/code-review.txt")" --name "evolution-code-review" || echo "   (code-review gagal, cek sintaks jadwal)"
echo "   Cek: hermes cron list"

# 6. Watchdog (COPY saja — pasang manual karena butuh sudo + crontab)
echo ">> [6/7] Watchdog (manual)..."
mkdir -p "$HERMES_HOME/watchdog"
cp "$REPO_DIR/scripts/watchdog/"*.sh "$HERMES_HOME/watchdog/"
chmod +x "$HERMES_HOME/watchdog/"*.sh
echo "   File dicopy ke $HERMES_HOME/watchdog/. Pasang manual:"
echo "   sudo bash $HERMES_HOME/watchdog/bootstrap.sh"
echo "   (crontab -l 2>/dev/null; echo '*/15 * * * * $HERMES_HOME/watchdog/watchdog.sh >> $HERMES_HOME/watchdog.log 2>&1') | crontab -"

# 7. Learning loop + autonomy — MERGE MANUAL
echo ">> [7/7] Learning loop + autonomy (MANUAL):"
echo "   Merge config/learning.yaml DAN config/autonomy.yaml ke $HERMES_HOME/config.yaml pakai editor."
echo "   Lihat docs/ENABLE-LEARNING.md (learning), docs/TOOLS.md (reasoning effort, browser, MCP),"
echo "   docs/EXECUTION.md (disiplin eksekusi). Webhook opsional: docs/WEBHOOKS.md."

echo ""
echo "== SELESAI =="
echo "- SOUL.md aktif mulai sesi berikutnya."
echo "- Cron jobs jalan di gateway (harus aktif + Telegram terkonfigurasi)."
echo "- Test: hermes cron trigger evolution-heartbeat"
