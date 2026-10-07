# TOOLS — bikin pemanggilan tools Hermes powerful

Hermes upstream sudah punya semuanya (browser automation, sandboxed code execution, MCP).
File ini = cara mengaktifkan + urutan pakai yang benar. Jangan asal enable semua.

## 1. Otak lebih pinter: reasoning effort

- Global: `agent.reasoning_effort: high` (sudah di `config/autonomy.yaml`).
- Per cron job (berat vs ringan beda kebutuhan):
  ```bash
  hermes cron edit evolution-daily-review --reasoning-effort high     # analisis → mikir dalam
  hermes cron edit evolution-heartbeat --reasoning-effort minimal     # cek rutin → hemat
  hermes cron edit evolution-morning-briefing --reasoning-effort medium
  ```
- Level: `none | minimal | low | medium | high | xhigh | max | ultra`.
  Model yang nggak support di-clamp otomatis — aman.

## 2. Web: tangga yang benar

Jangan langsung browser automation untuk semua. Urutan termurah → termahal:

1. **Search skill** (gratis, cepat): `research-duckduckgo-search`, `research-searxng-search`
   → buat "ada info apa tentang X".
2. **Fetch langsung** (gratis): ambil URL spesifik → buat "isi halaman ini apa".
3. **Browser automation** (berat): HANYA kalau butuh interaksi — login, klik, form, JS berat,
   anti-bot. Pilihan backend:
   - **Lokal gratis**: Chromium via CDP (`/browser connect` ke Chrome yang jalan di home server),
     atau Lightpanda (headless, ringan, tanpa Chromium).
   - **Cloud berbayar**: Browser Use / Browserbase / Firecrawl — stealth + proxy + CAPTCHA solving.
     Butuh API key di `~/.hermes/.env` (`BROWSER_USE_API_KEY` dll).
   - **Nous subscriber**: `hermes setup --portal` → semua tool gateway aktif tanpa key terpisah.

Aturan: skill research bawaan cukup untuk 90% kebutuhan (termasuk morning briefing).
Browser automation = senjata terakhir, bukan pertama.

## 3. Eksekusi kode: sandbox kernel

- Hermes jalanin kode di **sandboxed kernel** (bukan shell liar). State kernel frozen saat spawn —
  kalau env berubah (allowlist baru), pass `reset: true` untuk mulai bersih.
- Disiplin: **verifikasi dengan menjalankan, bukan dengan membaca.** Klaim "beres" = ada output
  run yang membuktikan, bukan "kodenya keliatan bener".
- Remote backend (Docker/SSH) butuh Python 3 di sisi sana.

## 4. Skill yang worth di-enable buat dunianya Sir

Bundled (ada di repo upstream, tinggal enable):
- `research-*` — riset web buat briefing & affiliate.
- `software-development-*` — coding workflow.
- `devops-*` — server ops.

Custom (dari pack ini, sudah di `skills/`): `taskrelay`, `stack-health`, `affiliate-pipeline`.

Cek yang aktif: `hermes skills list`. Kurator (`curator:`) akan prune yang nganggur otomatis —
jangan panik kalau skill yang 30 hari nggak dipakai masuk arsip.

## 5. MCP (kalau butuh tools di luar bawaan)

`hermes mcp` — sambungkan server MCP eksternal (misal: Playwright MCP buat browser yang lebih
powerful, atau MCP custom buat API yang sering dipakai Sir). MCP yang tidak pernah dipakai
akan diblokir preflight cron — jadi daftarkan yang beneran dipakai aja.
