#!/usr/bin/env bash
# watchdog.sh — cek gateway tiap 15 menit via crontab, bootstrap ulang kalau mati.
# Pasang: (crontab -l 2>/dev/null; echo "*/15 * * * * $HOME/hermes-evolution/scripts/watchdog/watchdog.sh >> $HOME/.hermes/watchdog.log 2>&1") | crontab -
set -uo pipefail

SERVICE_NAME="hermes-gateway"
# Pola proses yang dicari — sesuaikan dengan SERVICE_CMD di bootstrap.sh
PROC_PATTERN="${HERMES_GATEWAY_PATTERN:-hermes serve}"
LOG="$HOME/.hermes/watchdog.log"
TS="$(date '+%Y-%m-%d %H:%M:%S')"

log() { echo "[$TS] $*" >> "$LOG"; }

if pgrep -f "$PROC_PATTERN" >/dev/null 2>&1 && sudo systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
  log "OK gateway hidup"
  exit 0
fi

log "WARN gateway mati, bootstrap ulang..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if bash "$SCRIPT_DIR/bootstrap.sh" >> "$LOG" 2>&1; then
  log "OK pulih via bootstrap"
else
  log "FAIL bootstrap gagal — butuh tangan Sir"
fi
