# Mengaktifkan learning loop bawaan hermes-agent

Hermes (NousResearch) sudah punya learning loop built-in. Ini checklist memastikan semuanya AKTIF —
tanpa ini, "evolution pack" cuma jalan setengah.

## 1. Background review (memory + skill capture tiap turn)

Di `~/.hermes/config.yaml`:

```yaml
auxiliary:
  background_review:
    enabled: true
```

Ini bikin tiap turn di-fork ke review yang menangkap memory dan mengusulkan skill baru.
Butuh model yang bisa dipanggil — default-nya pakai model chat utama.
Kalau mau hemat token, arahkan ke model murah:

```yaml
auxiliary:
  background_review:
    provider: openrouter
    model: google/gemini-3-flash-preview
```

Cek: `hermes config get auxiliary.background_review.enabled` → harus `true`.

## 2. Nudge interval (seberapa agresif dia belajar)

```yaml
memory:
  nudge_interval: 10      # default konservatif; angka kecil = lebih sering nulis memory
skills:
  creation_nudge_interval: 10
```

## 3. Kurator skill (rapihin library tiap 24 jam)

```yaml
curator:
  enabled: true
  interval_hours: 24
```

Cek status: `hermes curator status`
Jalankan manual sekali: `hermes curator run --dry-run` (lihat dulu, baru `hermes curator run`)

## 4. Verifikasi semuanya jalan

```bash
hermes curator status          # kurator aktif?
hermes cron list               # evolution-daily-review + evolution-heartbeat ada?
hermes cron trigger evolution-heartbeat   # test heartbeat sekali
```

## Catatan model

Cron job Hermes jalan di: per-job pin → `cron.model` di config.yaml → model utama (`hermes model`).
Kalau model utama Sir = `muse` via 9Router, cron jobs ikut pakai itu — pastikan 9Router +
muse-bridge hidup saat job jalan, atau pin cron ke provider lain:

```bash
hermes config set cron.model <nama-model>
```
