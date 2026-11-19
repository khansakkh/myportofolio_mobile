# MyPortfolio Mobile

Aplikasi portofolio Flutter milik Khansa Khairunnisa Haikal (2506536465), PBP C. Proyek ini melanjutkan Tutorial 08, Tugas 7, dan Tutorial 09 PBP Gasal 2026/2027.

## Menjalankan aplikasi

1. Pasang Flutter SDK dan ekstensi Flutter/Dart pada IDE.
2. Jalankan `flutter doctor` untuk memeriksa lingkungan pengembangan.
3. Pada root proyek, jalankan `flutter pub get`.
4. Jalankan `flutter run -d chrome`, atau pilih emulator/perangkat melalui `flutter devices` dan `flutter run`.

## Progres

- Tutorial 08: memisahkan bootstrap dan tema pada `lib/main.dart` dari halaman `lib/menu.dart`; membuat InfoCard dan ItemCard serta pesan SnackBar.
- Tugas 7: mengganti profil contoh dengan identitas pribadi dan menambahkan atribut `Color` pada ItemHomepage. Lihat Proyek memakai biru, Tambah Proyek hijau, dan Logout merah. Setiap tombol menampilkan `Kamu telah menekan tombol [Nama Tombol]!`.
- Tutorial 09: drawer Home/Add Project, formulir proyek, dialog hasil input, navigasi tombol Tambah Proyek, dan pemisahan halaman dari widget. Tombol Lihat Proyek dan Logout masih menampilkan SnackBar.

## Tutorial 09

Implementasi mengikuti urutan tutorial:

1. Membuat `LeftDrawer` dengan header My Portfolio dan menu Home/Add Project. Kedua menu menggunakan `Navigator.pushReplacement`.
2. Membuat `ProjectFormPage` sebagai `StatefulWidget` dengan `GlobalKey<FormState>`. Field nama dan deskripsi wajib diisi (spasi saja ditolak); kategori memiliki lima pilihan; teknologi dan tautan opsional.
3. Tombol Save memvalidasi formulir dan menampilkan kelima isian dalam `AlertDialog`. Tombol OK menutup dialog dan mengosongkan input, termasuk mengembalikan kategori ke Web Development. Data belum disimpan ke database.
4. Tombol Tambah Proyek tetap menampilkan SnackBar, kemudian membuka form menggunakan `Navigator.push`, sehingga pengguna dapat kembali ke menu sebelumnya.
5. Memindahkan halaman melalui VS Code ke `lib/screens/` dan memisahkan `ItemCard` ke `lib/widgets/project_card.dart`, lalu menyesuaikan impor. Komponen Material diimpor dari paket `material_ui` sesuai PDF.

| Berkas | Peran |
| --- | --- |
| `lib/main.dart` | Konfigurasi tema dan halaman awal |
| `lib/screens/menu.dart` | Halaman utama, kartu identitas, dan model ItemHomepage |
| `lib/screens/project_form.dart` | Form, validasi, dialog, dan reset |
| `lib/widgets/left_drawer.dart` | Drawer navigasi bersama |
| `lib/widgets/project_card.dart` | Kartu aksi dan navigasi Tambah Proyek |

Pemeriksaan akhir Tutorial 09:

- Format Dart dan `git diff --check`: lulus.
- `flutter analyze --no-pub`: **No issues found**.
- `flutter test --no-pub`: **4 tests passed**.
- `flutter build web --no-pub`: berhasil menghasilkan `build/web`.

## Pemeriksaan

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web
```

Tes widget memeriksa identitas dan aksi menu pada layar 360 x 640, navigasi push/pushReplacement, validasi input kosong/spasi, isi dialog, serta reset semua field dan kategori setelah OK.

### Tugas 7

1. **Widget tree dan hubungan parent-child**

   Widget tree adalah susunan widget secara hierarkis untuk mendeskripsikan antarmuka. Parent membungkus atau menampung child melalui properti seperti `child`, `children`, `home`, atau `body`. Pada aplikasi ini, `MaterialApp` menampung `MyHomePage`, lalu halaman membangun `Scaffold` dengan `AppBar` dan konten. `Column` menyusun kartu profil serta menu secara vertikal, sedangkan `Row` menyusun tiga InfoCard secara horizontal. Parent meneruskan batas ukuran ke child, child menentukan ukuran dalam batas itu, lalu parent menentukan posisinya. Tree juga menentukan cakupan informasi tema dan lokasi ScaffoldMessenger.

2. **Widget yang digunakan dan fungsinya**

   | Widget | Fungsi dalam proyek |
   | --- | --- |
   | MyApp | Widget stateless akar aplikasi yang membangun MaterialApp. |
   | MaterialApp | Menyiapkan aplikasi Material, tema, dan halaman awal. |
   | MyHomePage | Menyusun halaman utama portofolio tanpa state lokal yang berubah. |
   | Scaffold | Struktur halaman dengan app bar dan body. |
   | AppBar | Menampilkan judul di bagian atas. |
   | Text | Menampilkan judul, profil, label menu, dan pesan. |
   | SingleChildScrollView | Memungkinkan konten halaman digulir bila melebihi tinggi layar. |
   | Padding | Memberi ruang di sekitar konten. |
   | Column | Menyusun beberapa widget secara vertikal. |
   | Row | Menyusun kartu profil secara horizontal. |
   | Expanded | Membagi lebar Row secara merata untuk InfoCard. |
   | InfoCard | Komponen buatan sendiri untuk judul dan isi identitas. |
   | Card | Permukaan kartu profil dengan elevation. |
   | SizedBox | Memberikan jarak antarbagian. |
   | GridView.count | Menyusun tiga aksi dalam grid tiga kolom. |
   | ItemCard | Komponen buatan sendiri untuk satu aksi menu. |
   | Material | Permukaan berwarna yang mendukung efek tinta InkWell. |
   | InkWell | Menangani ketukan pada kartu dan menampilkan efek sentuhan. |
   | Icon | Menampilkan simbol folder, tambah, dan logout. |
   | Flexible | Membatasi teks menu dalam ruang Column yang tersedia. |
   | SnackBar | Menampilkan umpan balik sementara setelah tombol ditekan. |

   `ItemHomepage` merupakan model data, bukan widget. `Theme`, `ScaffoldMessenger`, dan `MediaQuery` menyediakan inherited state dalam tree yang disiapkan framework; kode memakai `Theme.of(context)` serta `ScaffoldMessenger.of(context)` untuk mengaksesnya. `Color`, `TextStyle`, dan `EdgeInsets` adalah konfigurasi, bukan widget.

3. **Fungsi MaterialApp**

   MaterialApp menyediakan konfigurasi tingkat aplikasi seperti tema, judul, halaman awal, navigasi, lokalisasi, serta dukungan komponen Material. Pada proyek ini, `home` menunjuk MyHomePage dan `theme` memakai Material 3 dengan warna dasar indigo. MaterialApp lazim menjadi widget utama yang dikembalikan root widget karena halaman di bawahnya dapat memakai tema dan fasilitas navigasi yang konsisten tanpa mengaturnya berulang kali. Pada proyek ini root yang diberikan ke runApp adalah MyApp, yang kemudian membangun MaterialApp.

4. **StatelessWidget dan StatefulWidget**

   StatelessWidget tidak memiliki objek State untuk menyimpan state lokal yang berubah selama widget hidup. Tampilan berasal dari konfigurasi dan informasi di context. Widget ini tetap dapat dibangun ulang ketika parent atau inherited dependency berubah. StatefulWidget memiliki objek State terpisah; perubahan melalui setState menjadwalkan pembangunan ulang. Gunakan StatelessWidget untuk kartu informasi atau halaman yang datanya tetap seperti menu ini. Gunakan StatefulWidget saat perlu state lokal, misalnya penghitung, pilihan filter, atau status password tersembunyi. Menampilkan SnackBar tidak mengharuskan MyHomePage menjadi StatefulWidget karena state tampilan pesan dikelola ScaffoldMessenger.

5. **BuildContext**

   BuildContext adalah referensi lokasi widget dalam tree. Parameter context di `build(BuildContext context)` dapat digunakan untuk mencari informasi atau layanan dari ancestor yang sesuai. `Theme.of(context).colorScheme.primary` mengambil warna tema untuk AppBar. `ScaffoldMessenger.of(context)` menemukan pengelola SnackBar dan menampilkan pesan aksi. Context harus berada dalam cakupan ancestor yang dibutuhkan; context di atas MaterialApp, misalnya, tidak dapat mengakses fasilitas yang baru dibuat di bawah MaterialApp tersebut. Pada operasi asynchronous, periksa `context.mounted` sebelum memakai context setelah await bila widget mungkin sudah dilepas.

6. **Hot reload, hot restart, dan full restart**

   Hot reload memperbarui kode Dart pada sesi debug dan membangun ulang tampilan sambil mempertahankan State yang sudah ada. Ini cocok untuk iterasi widget, teks, warna, dan layout. Hot restart menjalankan ulang aplikasi Dart, sehingga State hilang dan main serta inisialisasi dijalankan kembali. Perubahan initializer variabel global/static atau logika initState dapat membutuhkan hot restart agar inisialisasi baru berlaku. Perubahan struktur tertentu seperti perubahan enum menjadi class juga tidak didukung hot reload. Full restart menghentikan dan menjalankan ulang proses aplikasi; ini diperlukan untuk perubahan kode native Kotlin/Java/Swift/Objective-C atau konfigurasi platform dan plugin yang memerlukan build ulang. Karena itu, hot reload tidak menggantikan semua jenis restart.

## Bantuan AI

ChatGPT (OpenAI) digunakan untuk membaca checklist tugas, membantu perubahan kode profil dan warna menu, menyusun penjelasan reflektif, serta menjalankan pemeriksaan. Bantuan pada Tutorial 08 mencakup implementasi awal dan dokumentasi. Pada Tugas 7, perubahan berada pada `lib/menu.dart`, tes widget, dan README ini.

Ringkasan prompt yang digunakan: mengerjakan Tugas 7 pada proyek yang sudah ada; mencari folder proyek di laptop; membuat commit bertahap dengan pesan perubahan yang deskriptif; memeriksa hasil dan melakukan merge. Kelas PBP C diberikan langsung oleh pengguna. Identitas contoh Burhan diganti dengan identitas pemilik, dan perubahan warna mengikuti atribut model tanpa percabangan berdasarkan nama tombol.

Keterbatasan: keluaran AI perlu diperiksa terhadap instruksi asli dan hasil alat pemeriksaan. Keberhasilan pemeriksaan lokal tidak membuktikan push GitHub berhasil atau hasil sudah dikumpulkan di SCELE.

## Hasil pemeriksaan Tugas 7

- `dart format --output=none --set-exit-if-changed lib test`: lulus, tidak ada perubahan format.
- `flutter analyze --no-pub`: **No issues found**.
- `git diff --check`: lulus.
- `flutter test --no-pub`: belum dapat memuat test suite karena koneksi WebSocket localhost diblokir lingkungan eksekusi (SocketException 10057); hasil ini tidak membuktikan tes aplikasi lulus atau gagal.
- Build web Tugas 7 belum diverifikasi.
