---
name: stack-health
description: Cek kesehatan stack LLM Sir (9Router, muse-bridge, TaskRelay) dari home server via endpoint publik. Pakai untuk heartbeat, morning briefing, dan diagnosis "kok Hermes lemot/mati".
---

# Stack Health Skill

Stack-nya jalan di VPS Shania, TAPI bisa dicek dari home server via URL publik. Localhost (`127.0.0.1`)
di skill ini = VPS Shania, BUKAN home server — dari sini selalu pakai URL publik.

## Endpoint & ekspektasi sehat

| Komponen | Cek | Sehat |
|---|---|---|
| TaskRelay | `GET https://relay.sirihsan.my.id/api/health` | HTTP 200, `{"ok": true, "version": "1.2.0"}` |
| 9Router | `GET https://9.sirihsan.my.id/v1/models` header `Authorization: Bearer $NINEROUTER_KEY` | HTTP 200, list berisi `muse` dan `ms/muse` |
| muse-bridge | tidak ada endpoint publik langsung — infer dari 9Router: kalau `muse` ada di `/v1/models` dan chat test jawab, bridge hidup |

Kunci 9Router: dipegang Sir (dulu di-backup di VPS Shania). Kalau 401 → key salah/ke-reset, minta Sir.

## Pola failure yang diketahui (dari pengalaman)

1. **Cloudflare 530 / error 1033** persis setelah VM replacement di VPS Shania → tunnel lagi bootstrap.
   Tunggu 2-5 menit, retry. BUKAN error permanen.
2. **403 error 1010 di `/api/*`** dengan curl polos → quirk Cloudflare: set header
   `User-Agent: Mozilla/5.0 (X11; Linux x86_64) Chrome/126`. Bukan key salah.
3. **9Router 401** di `/v1/models` → auth enforced, normal. Berarti service HIDUP tapi key salah.
4. **Timeout total** >30 detik di semua endpoint → kemungkinan VM lagi di-replace. Tunggu 5-10 menit, cek lagi.

## Kalau ada yang down

- JANGAN coba benerin dari home server — kamu nggak punya akses ke VPS Shania. Service di sana
  self-healing via watchdog (15 menitan).
- Yang kamu lakukan: catat WAKTU down-nya, retry tiap 5 menit (maks 3x), kalau masih down setelah
  15 menit → kabari Sir via Telegram (ini memenuhi syarat "worth ganggu": service kritis down).
- Kalau TaskRelay down: JANGAN submit task baru sampai health kembali 200 (submit-nya bakal gagal).

## Test end-to-end (kalau ragu bridge/9Router beneran jawab)

```bash
curl -s --max-time 30 https://9.sirihsan.my.id/v1/chat/completions \
  -H "Authorization: Bearer $NINEROUTER_KEY" \
  -H "Content-Type: application/json" \
  -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64) Chrome/126" \
  -d '{"model":"muse","messages":[{"role":"user","content":"balas dengan kata: ok"}],"max_tokens":10}'
```

Harus HTTP 200 dengan jawaban. ~9 detik itu normal (dijawab worker Shania via file-queue).
