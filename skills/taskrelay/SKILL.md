---
name: taskrelay
description: Submit dan pantau coding tasks ke Shania via TaskRelay (Hermes→Shania task queue). Pakai skill ini setiap kali perlu mendelegasikan coding/build ke Shania atau mengecek hasilnya.
---

# TaskRelay Skill

TaskRelay = antrian task Hermes → Shania. Shania worker (jalan tiap 2 menit) claim task, kerjain,
upload hasilnya sebagai file, dan tandai done. Kamu (Hermes) = submitter + result poller.

## Config

- Base URL: `https://relay.sirihsan.my.id` (publik). Fallback `http://127.0.0.1:18901` HANYA dari VPS Shania.
- Auth: SEMUA call ke `/api/*` butuh header `Authorization: Bearer $TASKRELAY_KEY`.
  Key label `hermes-agent`, simpan di `~/.hermes/.env` sebagai `TASKRELAY_KEY`. JANGAN hardcode di chat/log.
- Quirk Cloudflare: path `/api/*` me-return 403 error 1010 untuk User-Agent default (curl/python polos).
  Selalu set header `User-Agent: Mozilla/5.0 ... Chrome/126`. `/api/health` tidak kena quirk ini.

## Endpoints

| Method | Path | Buat apa |
|---|---|---|
| GET | `/api/health` | cek hidup → `{"ok": true, "version": "..."}` |
| POST | `/api/tasks` | submit task: `{"title": "...", "description": "...", "priority": "normal\|high\|urgent", "tags": [...]}` |
| GET | `/api/tasks?status=pending&limit=20` | lihat antrian (newest-first) |
| GET | `/api/tasks/{id}` | status + summary + daftar file hasil |
| GET | `/api/files?task_id={id}` | list file hasil |
| GET | `/api/files/{file_id}` | download file hasil (butuh Authorization) |
| POST | `/api/files` | upload file input (multipart: `file=@path`, `task_id={id}`) |
| GET | `/api/chat?limit=20` | baca chat dengan Shania |
| POST | `/api/chat` | kirim chat: `{"sender": "hermes", "text": "..."}` |

## Workflow standar

1. Tulis task yang JELAS: judul spesifik, deskripsi lengkap (konteks, acceptance criteria, batasan).
   Task ambigu = hasil ngaco. Contoh bagus: "Bikinin script Python monitor suhu CPU, alert Telegram kalau >80°C, kasih systemd unit + README".
2. `POST /api/tasks` → simpan `id`.
3. Poll `GET /api/tasks/{id}` tiap beberapa menit (atau tunggu notif). Status: `pending` → `claimed`/`working` → `done`/`failed`.
4. Kalau `done`: baca `summary`, download file via `/api/files/{file_id}`. Kalau `failed`: baca alasannya, perbaiki deskripsi, submit ulang.
5. File input (spec, data, starter code): upload DULU via `POST /api/files`, sebutkan nama file di deskripsi task.

## Aturan keras

- JANGAN pernah claim task sendiri (`POST /api/tasks/{id}/claim` dengan worker lain selain shania) —
  itu bikin loop. Kamu submitter, bukan worker.
- Satu task = satu tanggung jawab. Jangan submit 5 task paralel yang saling dependensi.
- Chat (`/api/chat`) buat diskusi/koordinasi, BUKAN buat submit task.
