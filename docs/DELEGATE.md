# Parallel Delegates Playbook — kerjaan gede dikerjain bareng-bareng

Hermes bisa spawn subagents buat kerja paralel. Playbook ini = kapan dan gimana.

## Kapan paralelisasi WORTH

- Task punya 3+ workstream yang INDEPENDEN (hasil A tidak dibutuhkan untuk mulai B).
  Contoh: riset 3 produk affiliate sekaligus; bangun backend + frontend + nulis docs.
- Riset + eksekusi bisa jalan bareng (satu agen cari data, satu agen bikin kerangka kode).

## Kapan JANGAN

- Langkahnya dependen (B butuh output A) → kerjain sekuensial, jangan maksa paralel.
- Task kecil (<5 menit) → overhead spawn lebih mahal dari manfaatnya.
- Butuh konteks yang sama persis di semua sisi → satu agen aja, nanti halu beda-beda.

## Cara fan-out

1. Pecah task jadi workstream independen, tiap-tiap dengan brief TERTULIS yang sempit:
   - Tujuan 1 kalimat, input yang tersedia, output yang diharapkan (format file!), batasan.
   - Subagent TIDAK lihat percakapan utama — brief harus self-contained.
2. Spawn SEMUA sekaligus (jangan satu-satu nunggu).
3. Tiap subagent: kerja sampai selesai, return hasil ringkas + file.
4. Kamu (orkestrator): gabungkan, cek konsistensi antar hasil, verifikasi akhir.
   Jangan langsung forward mentah ke Sir — kamu yang tanggung jawab atas gabungannya.

## Template brief subagent

```
Konteks: [1-2 kalimat: ini bagian dari task besar apa]
Tugasmu: [spesifik, 1 paragraf]
Input: [file/data/path yang bisa kamu baca]
Output: [file yang harus kamu tulis + formatnya]
Batasan: [yang TIDAK boleh dilakukan]
Selesai kalau: [kriteria konkret]
```

## Aturan

- Maksimal 4-5 subagent paralel untuk task biasa. Lebih dari itu = susah digabung.
- Subagent TIDAK boleh spawn subagent lagi (no nesting).
- Kalau satu subagent gagal: nilai apakah hasilnya bisa diganti/diskip. Jangan retry buta 3x.
- Token budget: delegasi paralel itu mahal. Untuk task rutin/murah, kerjain sendiri aja.
