# Hermes Evolution Pack

Bikin Hermes (NousResearch hermes-agent) jadi: **belajar dari kesalahan tiap hari, makin lama makin
pinter, proaktif inisiatif sendiri, dan punya kepribadian yang hidup** — tanpa ngerombak source code
upstream. 80% fondasinya (learning loop, skill self-improve, cron, memory search) sudah ada di
hermes-agent versi terbaru; pack ini nambahin 20% yang belum ada.

## Isi paket

| File | Buat apa |
|---|---|
| `soul/SOUL.md` | Persona Hermes yang hidup: blak-blakan, kasual (gue/lu), peduli, jujur soal salah |
| `cron/daily-review.txt` | Job harian 23:30 — review sesi kemarin, ekstrak kesalahan → tulis pelajaran ke memory, bikin/patch skill |
| `cron/heartbeat.txt` | Job tiap 45 menit — cek dunia, mutusin sendiri worth ngabarin Sir atau diem (+ care check) |
| `cron/morning-briefing.txt` | Briefing 07:00: ringkasan semalam + server + TaskRelay + tren affiliate + fokus hari ini |
| `cron/weekly-review.txt` | Review mingguan tiap Minggu 20:00: audit goals.yaml, nagih yang stagnan |
| `cron/code-review.txt` | Review push GitHub (dipicu webhook, bukan jadwal): cek diff, jalanin test, lapor |
| `skills/taskrelay/` | Skill: submit/poll task ke Shania via TaskRelay |
| `skills/stack-health/` | Skill: cek kesehatan 9Router/muse-bridge/TaskRelay + pola failure yang diketahui |
| `skills/affiliate-pipeline/` | Skill: jalanin pipeline affiliate-flow (perintah, prasyarat, batasan) |
| `config/goals.yaml` | Daftar goal Sir (dibaca/ditulis weekly-review) |
| `user/USER.md` | Profil Sir (nama, lokasi, kerjaan, spek home server, instruksi) → di-copy ke $HERMES_HOME/USER.md |
| `config/webhooks.yaml` | Snippet route webhook GitHub push → fire code-review |
| `docs/WEBHOOKS.md` | Setup webhook adapter + GitHub |
| `docs/DELEGATE.md` | Playbook paralel: kapan fan-out ke subagents, template brief |
| `scripts/watchdog/` | bootstrap.sh (systemd idempoten) + watchdog.sh (cron 15 mnt) buat gateway Hermes |
| `config/guardrails.yaml` | Rem proaktivitas: quiet hours 23:00–07:00, max 3 pesan/hari, topik yang boleh/tidak |
| `config/learning.yaml` | Snippet buat `config.yaml`: aktifin background review + kurator skill 24 jam |
| `docs/ENABLE-LEARNING.md` | Checklist verifikasi learning loop bawaan |
| `scripts/install.sh` | One-shot installer |

## Install (di HOME SERVER, bukan di VPS)

```bash
git clone https://github.com/bismillah123-jp/hermes-evolution.git
cd hermes-evolution
./scripts/install.sh
# lalu merge config/learning.yaml ke ~/.hermes/config.yaml manual (lihat docs/ENABLE-LEARNING.md)
```

Syarat:
- `hermes` CLI terinstall dan sudah `hermes update` ke versi terbaru (Oktober 2026+)
- Gateway jalan (`hermes serve`) + Telegram terkonfigurasi — buat cron delivery & heartbeat
- Model utama jalan (cron jobs ikut model utama kecuali di-pin)

## Yang pack ini TIDAK lakukan (jujur)

- **Perasaan beneran: tidak ada.** Yang ada = simulasi kepribadian konsisten + memory konteks emosional.
  Kalau ditanya langsung, Hermes akan jujur soal ini (tertulis di SOUL.md).
- **Tidak fork upstream.** Ini layer di atas hermes-agent resmi. Update upstream = `hermes update`, pack tetap jalan.

## Cara kerja hariannya

1. Tiap turn → background review capture memory + usul skill (bawaan upstream).
2. Tiap 45 menit → heartbeat cek kondisi; ganggu Sir cuma kalau beneran penting (max 3x/hari).
3. Tiap malam 23:30 → daily review: audit semua sesi, tulis pelajaran dari kesalahan, bikin/patch skill, lapor ringkas ke Telegram.
4. Tiap 24 jam → kurator rapihin skill yang nganggur (bawaan upstream).

## Kustomisasi

- `config/guardrails.yaml` — ubah quiet hours, limit, topik, service yang di-watch.
- `soul/SOUL.md` — ubah kepribadian sesukamu, backup otomatis dibuat tiap install.
- Jadwal cron — edit via `hermes cron edit <nama>` atau daftarkan ulang.
