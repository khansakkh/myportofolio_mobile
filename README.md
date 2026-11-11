# MyPortfolio Mobile

Proyek Flutter untuk Tutorial 08 PBP Gasal 2026/2027. Halaman utama menampilkan identitas contoh Burhan serta tiga kartu menu interaktif.

## Menjalankan aplikasi

1. Pasang Flutter SDK dan ekstensi Flutter/Dart untuk VS Code.
2. Jalankan `flutter doctor` untuk memeriksa toolchain.
3. Dari folder proyek, jalankan `flutter pub get`.
4. Jalankan `flutter run -d chrome` untuk membuka aplikasi web.

## Isi tutorial

- `lib/main.dart` berisi entry point dan tema Material 3 dengan warna indigo serta amber.
- `lib/menu.dart` berisi halaman stateless, `InfoCard`, `ItemHomepage`, dan `ItemCard`.
- Tiga tombol menampilkan SnackBar sesuai nama tombol yang ditekan.
- Kartu informasi membagi ruang dengan `Expanded`. Halaman bisa digulir agar konten tetap dapat dibaca pada layar kecil.
- Identitas contoh mengikuti panduan Tutorial 08. Penyesuaian identitas dan menu pribadi dilakukan pada Individual Assignment 7.

## Pemeriksaan

Jalankan `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, dan `flutter test`.

Tes widget memeriksa identitas dan ketiga pesan SnackBar pada ukuran layar 360 × 640.

Pemeriksaan Tutorial 08 dilakukan dengan Flutter 3.47.9 dan Dart 3.13.7.

- Format Dart sudah diperiksa.
- `flutter analyze` selesai dengan hasil `No issues found`.
- `flutter test` lulus untuk tes profil dan ketiga aksi menu.
- `flutter build web` berhasil.
- Halaman web diperiksa pada ukuran 360 × 640. Ketiga tombol menampilkan pesan SnackBar yang sesuai ketika diklik di browser.

Target yang diverifikasi adalah web. Build Android memerlukan Android SDK yang dikonfigurasi pada perangkat pengembang.

## Bantuan AI

Saya menggunakan ChatGPT (OpenAI) untuk memeriksa langkah tutorial satu per satu, membantu implementasi dan perbaikan kode, memeriksa hasil pengujian, serta merapikan README. Kode mengikuti pola widget pada Tutorial 08 dengan penyesuaian tata letak untuk layar kecil.
