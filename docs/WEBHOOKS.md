# Webhooks — Hermes reaktif terhadap event (GitHub push dll.)

Selain cron terjadwal, Hermes bisa langsung bereaksi saat sesuatu TERJADI via webhook.
Pola yang dipakai di sini: GitHub push → fire cron job `evolution-code-review`.

## 1. Aktifkan webhook adapter

Opsi A — wizard:

```bash
hermes gateway setup
```

Opsi B — environment, tambah ke `~/.hermes/.env`:

```bash
WEBHOOK_ENABLED=true
WEBHOOK_PORT=8644
WEBHOOK_SECRET=isi-dengan-string-acak-panjang
```

Buat secret acak: `openssl rand -hex 32`

Verifikasi gateway jalan:

```bash
curl http://localhost:8644/health
# {"status":"ok","platform":"webhook"}
```

## 2. Pasang routes

Merge `config/webhooks.yaml` ke `~/.hermes/config.yaml` di bawah key `platforms:`.
Lalu daftarkan cron job yang di-fire route tersebut:

```bash
hermes cron create "every 30d" "$(cat cron/code-review.txt)" --name "evolution-code-review"
```

(Jadwalnya jarang — yang penting job-nya ADA karena route mem-fire by name. Jangan hapus job-nya.)

Restart gateway setelah ubah config.

## 3. Arahkan GitHub ke Hermes

Di repo GitHub → Settings → Webhooks → Add webhook:

- Payload URL: `http://IP-HOME-SERVER:8644/webhooks/github-push`
  (kalau home server di belakang NAT: pakai tunnel/ngrok/Cloudflare Tunnel — atau batasi ke
  repo yang push-nya dari mesin lokal)
- Content type: `application/json`
- Secret: sama dengan `WEBHOOK_SECRET`
- Events: "Just the push event"

Test: `curl -X POST http://localhost:8644/webhooks/github-push -H 'Content-Type: application/json' -d '{}'`
(akan ditolak HMAC kalau secret diset — itu TANDA BERES, bukan error.)

## 4. Bikin route sendiri

Pola umum (lihat `config/webhooks.yaml`):

```yaml
routes:
  nama-route:
    events: ["push"]                    # event dari provider
    filters:                            # opsional: hanya payload yang cocok
      - field: "ref"
        equals: "refs/heads/main"
    cron_job: "nama-cron-job"           # fire job yang sudah ada
    # ATAU prompt langsung + deliver:
    # prompt: "Template dengan {field.dari.payload}"
    # deliver: "telegram"
```

Prompt mendukung template `{repository.full_name}`, `{head_commit.message}`, dll.
Route `cron_job` dan `deliver_only` tidak bisa digabung — pilih satu.

Referensi resmi: `website/docs/user-guide/messaging/webhooks.md` di repo NousResearch/hermes-agent.
