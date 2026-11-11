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

## Bantuan AI

ChatGPT (OpenAI) digunakan untuk membaca panduan, menyiapkan proyek di laptop, mengimplementasikan halaman, serta membantu pengujian dan dokumentasi. Kode mengikuti pola widget pada Tutorial 08 dengan penyesuaian tata letak untuk layar kecil.
