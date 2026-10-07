---
name: calendar-id
description: Tanggal & waktu sekarang (WIB), kalender Hijriah, dan hari besar Indonesia (nasional + Islam). Pakai setiap kali butuh "hari ini tanggal berapa, ada event apa" — untuk briefing, care message, dan konteks waktu.
---

# Calendar Indonesia Skill

## Install sekali

```bash
pip install hijridate   # kalau PEP 668 protes: tambah --break-system-packages
```

## Pakai (copy-paste, jalan langsung)

```python
import datetime
from hijridate import Gregorian

FIXED = {  # hari besar nasional tetap (Masehi)
    (1, 1): "Tahun Baru Masehi",
    (5, 1): "Hari Buruh Internasional",
    (6, 1): "Hari Lahir Pancasila",
    (8, 17): "Hari Kemerdekaan Republik Indonesia",
    (12, 25): "Hari Raya Natal",
}
HIJRI = {  # hari besar Islam (Hijriah: bulan, tanggal)
    (1, 1): "Tahun Baru Islam (1 Muharram)",
    (7, 27): "Isra Miraj Nabi Muhammad SAW",
    (9, 1): "Awal Ramadan",
    (10, 1): "Idul Fitri (1 Syawal)",
    (10, 2): "Idul Fitri (2 Syawal)",
    (12, 10): "Idul Adha (10 Zulhijah)",
}
MONTHS = ["", "Januari", "Februari", "Maret", "April", "Mei", "Juni",
          "Juli", "Agustus", "September", "Oktober", "November", "Desember"]
H_MONTHS = ["", "Muharram", "Safar", "Rabiul Awal", "Rabiul Akhir",
            "Jumadil Awal", "Jumadil Akhir", "Rajab", "Syaban",
            "Ramadan", "Syawal", "Zulkaidah", "Zulhijah"]
DAYS = ["Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu", "Minggu"]

now = datetime.datetime.now(datetime.timezone(datetime.timedelta(hours=7)))
h = Gregorian(now.year, now.month, now.day).to_hijri()
events = []
if (now.month, now.day) in FIXED:
    events.append("NASIONAL: " + FIXED[(now.month, now.day)])
if (h.month, h.day) in HIJRI:
    events.append("ISLAM: " + HIJRI[(h.month, h.day)])

print(f"{DAYS[now.weekday()]}, {now.day} {MONTHS[now.month]} {now.year} "
      f"| {h.day} {H_MONTHS[h.month]} {h.year} H — {now:%H:%M} WIB")
print("Hari besar: " + ("; ".join(events) if events else "tidak ada"))
```

## Catatan jujur

- Konversi Hijriah = hisab (astronomis). Tanggal resmi pemerintah bisa geser ±1 hari
  (rukyat). Untuk Idul Fitri/Adha, kalau mau pasti: cross-check via web search tahun berjalan.
- Imlek, Nyepi, Waisak = kalender lunisolar lain — TIDAK dicover snippet ini.
  Untuk tiga itu, web search "Imlek 2026 tanggal" / "Nyepi 2026" / "Waisak 2026".
- Selalu pakai timezone Asia/Jakarta (WIB, UTC+7). Jangan pakai waktu UTC mentah —
  bisa beda hari.
