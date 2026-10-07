---
name: affiliate-pipeline
description: Menjalankan pipeline video affiliate (repo affiliate-flow, Google Flow via gflow-cli). Pakai saat Sir minta bikin video produk baru atau melanjutkan video yang tertunda.
---

# Affiliate Pipeline Skill

Repo: `https://github.com/bismillah123-jp/affiliate-flow` (clone di home server / mesin kerja).

## Batasan keras (preferensi Sir, jangan dilanggar)

- **NO ffmpeg** di mana pun. Verifikasi video pakai PyAV, bukan ffmpeg.
- **NO voice-over pihak ketiga** (edge-tts dkk). VO dibakar langsung oleh Omni Flash saat generate.
- POV / hands-only, produk konsisten (Flow character), Bahasa Indonesia, teks minimal di layar.

## Perintah

```bash
cd ~/workspace/affiliate-flow   # atau lokasi clone

# 1. Selalu preflight dulu (cek project Flow + login + kuota)
python3 pipeline.py --preflight --project <nama-project-flow>

# 2. Produk BARU (nama bebas) — JANGAN pakai --product <slug> untuk produk baru,
#    itu hanya untuk slug yang sudah ada di products/
python3 pipeline.py --manual-name "Nama Produk Persis" --project <nama-project-flow>

# 3. Produk tanpa VO (ASMR): tambah --no-vo
python3 pipeline.py --manual-name "Natural Deodorant Tawas Spray" --no-vo --project affiliate-flow-2

# 4. Dry run (tidak bakar kuota Flow)
python3 pipeline.py --manual-name "..." --dry-run
```

## Prasyarat (cek sebelum run)

1. **Flow project ADA dan BISA DIBUKA di web Flow.** gflow-cli TIDAK punya command create-project
   (verifikasi ke repo resmi). Kalau project rusak (redirect 404), Sir harus hapus + bikin baru manual.
2. **Patch ter-apply** (kalau repo belum update): `preflight` + `no-vo`. Cek `git log`.
3. **Storyboard override** untuk produk custom: `data/storyboards/<slug>.json` (slug = hasil slugify
   dari --manual-name). Tanpa file ini → jatuh ke template generik 3 scene / 10 detik.
4. **Karakter produk**: foto produk diregistrasi sekali sebagai Flow character `aff-<slug>`.

## Yang perlu Sir tahu (jujur sebelum run)

- `lib/gen_video.py` saat ini bikin SATU klip 10 detik (`DURATION = 10`) — bukan 30 detik 3 part.
  Output = keyframes + 1 klip 10 detik. Jangan janjiin 30 detik jadi.
- Real generation butuh: login Google di gflow + kuota Flow. `--preflight` memverifikasi ini
  TANPA bakar kuota.
- Kuota Flow terbatas (angka pastinya dari Google, bukan dari kita) — dry-run dulu selalu.

## Kalau error

- `slug '<x>' tidak ada` → salah pakai `--product` untuk produk baru; pakai `--manual-name`.
- `Could not open project` → project Flow bermasalah; Sir bikin baru di web UI, lalu `--project <baru>`.
- `No Flow project is open` → jalanin `gflow doctor`, klik manual ke project di Chrome yang kebuka.
