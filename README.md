# MyPortfolio Mobile

Aplikasi mobile Flutter untuk portofolio pribadi, sebagai kelanjutan dari proyek website portofolio Django pada mata kuliah Pemrograman Berbasis Platform (PBP) Fasilkom UI, Semester Gasal 2026/2027.

| | |
|---|---|
| **Nama** | Andy Aulia Akbar |
| **NPM** | 2506613590 |
| **Kelas** | PBP C |

## Daftar Isi

- [Fitur](#fitur)
- [Struktur Proyek](#struktur-proyek)
- [Setup dan Menjalankan Aplikasi](#setup-dan-menjalankan-aplikasi)
- [Progres Mingguan](#progres-mingguan)
- [Pertanyaan Reflektif](#pertanyaan-reflektif)
  - [Tugas 7](#tugas-7)
  - [Tugas 8](#tugas-8)
- [AI Disclosure](#ai-disclosure)

## Fitur

- **Kartu identitas (`InfoCard`)**: tiga kartu di bagian atas halaman yang menampilkan NPM, nama, dan kelas.
- **Tombol aksi (`ItemCard`)**: empat kartu tombol dalam kisi 3 kolom:
  | Tombol | Ikon | Warna | Aksi |
  |---|---|---|---|
  | Lihat Proyek | `Icons.folder` | Biru | SnackBar |
  | Tambah Proyek | `Icons.add_circle` | Hijau | Membuka formulir proyek |
  | Tambah Edukasi | `Icons.school` | Oranye | Membuka formulir edukasi |
  | Logout | `Icons.logout` | Merah | SnackBar |
- **SnackBar interaktif**: menekan tombol memunculkan pesan "Kamu telah menekan tombol [Nama Tombol]!". SnackBar sebelumnya ditutup dulu, jadi pesan tidak menumpuk saat tombol ditekan berulang kali.
- **Warna berbasis model**: warna tiap tombol disimpan di model `ItemHomepage`, jadi `ItemCard` tidak memerlukan percabangan `if-else`.
- **Drawer navigasi (`LeftDrawer`)**: satu drawer yang sama dipakai di halaman utama dan kedua halaman formulir, berisi opsi **Home**, **Add Project**, dan **Add Education**.
- **Formulir Tambah Proyek** (Tutorial 09): nama, deskripsi, kategori, teknologi, dan tautan proyek, dengan ringkasan dalam dialog.
- **Formulir Tambah Edukasi** (Tugas 8):
  | Input | Widget | Validasi |
  |---|---|---|
  | Nama Institusi | `TextFormField` | Wajib, tidak boleh hanya spasi, maks. 100 karakter |
  | Jenjang Pendidikan | `DropdownButtonFormField` | Selalu terisi (default S1) |
  | Jurusan / Bidang Studi | `TextFormField` | Wajib, tidak boleh hanya spasi, maks. 100 karakter |
  | Tanggal Mulai | `TextFormField` read-only + `showDatePicker()` | Wajib |
  | Tanggal Selesai | `TextFormField` read-only + `showDatePicker()` | Wajib, tidak boleh sebelum tanggal mulai |
  | Deskripsi | `TextFormField` multiline | Opsional, maks. 500 karakter |

  Setelah semua input valid, tombol **Simpan** menampilkan ringkasan isian dalam `AlertDialog`. Tombol **OK** menutup dialog tanpa mengosongkan formulir, sehingga isian bisa langsung dikoreksi.
- **Halaman utama yang bisa digulir**: body dibungkus `SingleChildScrollView` agar kisi tombol tidak *overflow* di layar pendek.
- **Widget test**: identitas, warna tombol, SnackBar, drawer, navigasi, serta validasi dan dialog kedua formulir diuji secara otomatis (11 test).

## Struktur Proyek

```
lib/
├── main.dart                 # Titik masuk aplikasi: MyApp (MaterialApp + tema)
├── screens/
│   ├── menu.dart             # Halaman utama: MyHomePage, InfoCard
│   ├── project_form.dart     # Formulir Tambah Proyek (Tutorial 09)
│   └── education_form.dart   # Formulir Tambah Edukasi (Tugas 8)
└── widgets/
    ├── left_drawer.dart      # Drawer navigasi yang dipakai bersama
    └── project_card.dart     # Model ItemHomepage dan kartu aksi ItemCard
test/
└── widget_test.dart          # Widget test halaman utama, drawer, dan formulir
```

## Setup dan Menjalankan Aplikasi

### Prasyarat

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (dikembangkan dengan Flutter 3.38.6, channel stable)
- IDE dengan ekstensi Flutter/Dart (VS Code atau Android Studio)
- Emulator Android, perangkat fisik, atau browser Chrome

### Langkah

```bash
# 1. Clone repositori
git clone https://github.com/4aakbar/myportofolio_mobile.git
cd myportofolio_mobile

# 2. Unduh dependensi
flutter pub get

# 3. Jalankan aplikasi (pilih perangkat yang tersedia)
flutter run
# atau khusus browser:
flutter run -d chrome
```

### Pemeriksaan Kualitas Kode

```bash
flutter analyze   # harus menghasilkan "No issues found!"
flutter test      # menjalankan widget test
```

## Progres Mingguan

| Minggu | Tugas | Progres |
|---|---|---|
| 8 | Tutorial 08 | Setup proyek Flutter, memisahkan `menu.dart` dari `main.dart`, mengubah `MyHomePage` menjadi `StatelessWidget`, membuat `InfoCard` dan `ItemCard`. |
| 8 | Tugas 7 | Data identitas pribadi, atribut `color` pada `ItemHomepage`, warna unik untuk tiap tombol, docstring, widget test, README. |
| 9 | Tutorial 09 | Memisahkan kode ke `lib/screens/` dan `lib/widgets/`, membuat `LeftDrawer` dan formulir Tambah Proyek dengan validasi dan dialog, widget test drawer dan formulir. |
| 9 | Tugas 8 | Formulir Tambah Edukasi (input teks, dropdown, dan date picker), validasi panjang dan urutan tanggal, dialog ringkasan, kartu aksi dan opsi drawer baru, halaman utama yang bisa digulir, widget test formulir edukasi, README. |

## Pertanyaan Reflektif

### Tugas 7

1. **Widget tree dan hubungan parent-child**

   Di Flutter, seluruh antarmuka dibangun dari *widget*, dan widget-widget itu tersusun bertingkat membentuk sebuah pohon yang disebut *widget tree*. Setiap widget bisa memiliki satu anak (`child`) atau banyak anak (`children`), dan anak tersebut juga bisa memiliki anaknya sendiri.

   Hubungan parent-child bekerja seperti ini:
   - **Parent mengatur anak.** Parent menentukan batas ukuran (*constraints*) yang boleh dipakai anak, lalu anak menentukan ukurannya sendiri di dalam batas itu, dan parent yang menentukan posisinya. Prinsip ini sering diringkas sebagai *"constraints go down, sizes go up, parent sets position"*. Contohnya, `Padding` memberi anaknya ruang yang lebih kecil sebesar padding, sedangkan `Center` menaruh anaknya di tengah.
   - **Data mengalir dari atas ke bawah.** Parent mengirim data ke anak lewat parameter constructor. Di proyek ini, `MyHomePage` mengirim objek `ItemHomepage` ke `ItemCard(item)`.
   - **Anak bisa mengakses ancestor.** Melalui `BuildContext`, sebuah widget bisa mencari widget di atasnya, misalnya `Theme.of(context)` untuk tema dari `MaterialApp`, atau `ScaffoldMessenger.of(context)` untuk menampilkan SnackBar.

   Widget tree di proyek ini kurang lebih seperti berikut:
   ```
   MyApp
   └── MaterialApp
       └── MyHomePage
           └── Scaffold
               ├── AppBar → Text
               └── Padding → Column
                   ├── Row → InfoCard ×3 → Card → Container → Column → Text, SizedBox, Text
                   ├── SizedBox
                   └── Center → Column
                       ├── Padding → Text
                       └── GridView → ItemCard ×3 → Material → InkWell → Container → Center → Column → Icon, Padding, Text
   ```

2. **Widget yang digunakan dan fungsinya**

   | Widget | Fungsi di proyek ini |
   |---|---|
   | `MaterialApp` | Root aplikasi; menyediakan tema, navigasi, dan konfigurasi Material Design. |
   | `Scaffold` | Kerangka dasar halaman: tempat `AppBar`, `body`, dan SnackBar. |
   | `AppBar` | Bar di bagian atas halaman yang berisi judul "MyPortfolio". |
   | `Text` | Menampilkan teks: judul, isi kartu, nama tombol, dan pesan sambutan. |
   | `Padding` | Memberi jarak di sekeliling widget anak. |
   | `Column` | Menyusun anak-anaknya secara vertikal. |
   | `Row` | Menyusun ketiga `InfoCard` secara horizontal. |
   | `SizedBox` | Memberi jarak kosong dengan ukuran tetap antar-widget. |
   | `Center` | Menaruh anaknya di tengah ruang yang tersedia. |
   | `GridView` (`GridView.count`) | Menampilkan `ItemCard` dalam kisi 3 kolom. |
   | `Card` | Kotak dengan sudut membulat dan bayangan (elevation) untuk `InfoCard`. |
   | `Container` | Mengatur lebar dan padding isi kartu. |
   | `Material` | Memberi warna latar dan sudut membulat pada `ItemCard`, sekaligus menjadi permukaan untuk efek ripple `InkWell`. |
   | `InkWell` | Membuat area kartu bisa ditekan (`onTap`) dengan efek ripple. |
   | `Icon` | Menampilkan ikon pada tombol (`folder`, `add_circle`, `logout`). |
   | `SnackBar` | Pesan singkat di bagian bawah layar saat tombol ditekan. |
   | `ScaffoldMessenger` | Mengelola tampilan SnackBar (`hideCurrentSnackBar`, `showSnackBar`). |
   | `MediaQuery` | Membaca lebar layar untuk menentukan lebar `InfoCard`. |
   | `MyApp` | Widget kustom (Stateless) yang membungkus `MaterialApp`. |
   | `MyHomePage` | Widget kustom (Stateless) untuk halaman utama. |
   | `InfoCard` | Widget kustom (Stateless) untuk kartu identitas. |
   | `ItemCard` | Widget kustom (Stateless) untuk kartu tombol aksi. |

   `ItemHomepage` bukan widget. Class ini adalah model data biasa yang menyimpan nama, ikon, dan warna sebuah tombol.

3. **Fungsi `MaterialApp` dan alasan dipakai sebagai root widget**

   `MaterialApp` adalah widget yang menyiapkan semua yang dibutuhkan aplikasi bergaya Material Design, antara lain:
   - **Tema global** (`theme`): skema warna dan tipografi yang bisa diakses oleh semua widget di bawahnya melalui `Theme.of(context)`. Di proyek ini, `AppBar` mengambil warna dari `colorScheme.primary`.
   - **Navigasi**: menyediakan `Navigator` dan pengaturan rute (`home`, `routes`) untuk berpindah halaman.
   - **Lokalisasi dan arah teks**: menyediakan `Localizations` dan `Directionality` yang dibutuhkan widget seperti `Text`.
   - **Infrastruktur lain**: `ScaffoldMessenger` untuk SnackBar, `MediaQuery`, dan judul aplikasi (`title`).

   `MaterialApp` diletakkan sebagai root karena widget Material seperti `Scaffold`, `AppBar`, dan `SnackBar` bergantung pada konteks yang disediakan widget ini. Widget-widget tersebut mencari ancestor seperti `Theme`, `Navigator`, dan `ScaffoldMessenger` di atasnya. Kalau `MaterialApp` tidak berada di puncak tree, widget itu tidak menemukan ancestor yang dibutuhkan, sehingga muncul error atau tampilannya tidak sesuai. Dengan menaruhnya di root, seluruh halaman aplikasi otomatis mendapat konfigurasi yang konsisten.

4. **`StatelessWidget` vs `StatefulWidget`**

   | | `StatelessWidget` | `StatefulWidget` |
   |---|---|---|
   | State internal | Tidak ada; semua properti `final` | Ada, disimpan di objek `State` yang terpisah |
   | Kapan di-rebuild | Hanya ketika parent membangunnya ulang dengan data baru | Juga ketika `setState()` dipanggil |
   | Siklus hidup | Hanya `build()` | Ada `initState()`, `didUpdateWidget()`, `dispose()`, dan lainnya |
   | Contoh | Label, ikon, kartu informasi statis | Form input, checkbox, counter, data yang dimuat dari internet |

   **Pilih `StatelessWidget`** jika tampilan hanya bergantung pada data yang diterima dari luar dan tidak berubah karena interaksi pengguna. Seluruh widget di proyek ini Stateless karena NPM, nama, kelas, dan daftar tombol bersifat tetap. Menekan tombol hanya memunculkan SnackBar melalui `ScaffoldMessenger`, tanpa mengubah data milik widget itu sendiri.

   **Pilih `StatefulWidget`** jika widget harus mengingat dan memperbarui data selama ditampilkan, misalnya nilai yang diketik pengguna, status loading saat mengambil data dari server, atau animasi. Sebaiknya tetap gunakan Stateless sebisa mungkin dan batasi Stateful hanya pada bagian yang benar-benar berubah, supaya kode lebih sederhana dan rebuild lebih efisien.

5. **`BuildContext`**

   `BuildContext` adalah penanda posisi sebuah widget di dalam widget tree. Setiap widget menerima context-nya sendiri sebagai parameter metode `build(BuildContext context)`. Secara teknis, context ini adalah objek `Element` yang menghubungkan widget dengan tree.

   Context penting karena menjadi cara widget **mencari dan mengakses widget ancestor** yang menyediakan data atau layanan. Penggunaannya di dalam `build` pada proyek ini:
   - `Theme.of(context).colorScheme.primary` di `MyHomePage` untuk mengambil warna tema dari `MaterialApp`.
   - `MediaQuery.of(context).size.width` di `InfoCard` untuk membaca lebar layar.
   - `ScaffoldMessenger.of(context).showSnackBar(...)` di `ItemCard` untuk menampilkan SnackBar melalui `Scaffold` terdekat.

   Pencarian `.of(context)` selalu bergerak **ke atas** dari posisi context tersebut. Akibatnya, context yang dipakai harus berada di bawah widget yang dicari. Contohnya, memanggil `ScaffoldMessenger.of(context)` dengan context yang posisinya di atas `MaterialApp` akan gagal karena ancestor tersebut belum ada.

6. **Hot reload vs hot restart**

   - **Hot reload** (`r` di terminal, atau ikon petir di IDE) menyuntikkan kode yang baru diubah ke Dart VM yang sedang berjalan, lalu membangun ulang widget tree. **State aplikasi dipertahankan**, misalnya posisi scroll, halaman yang sedang dibuka, atau nilai variabel di `State`. Hasilnya muncul dalam hitungan detik, sehingga cocok untuk mengubah tampilan, warna, teks, atau isi metode `build`.
   - **Hot restart** (`R` di terminal) memuat ulang seluruh kode dan menjalankan aplikasi dari awal (`main()` dipanggil lagi). **State aplikasi di-reset**, tetapi prosesnya tetap lebih cepat daripada menghentikan dan menjalankan ulang aplikasi.
   - **Full restart** berarti menghentikan aplikasi lalu menjalankan `flutter run` lagi, sehingga aplikasi dikompilasi ulang dari nol.

   Hot reload **tidak cukup** dan perlu hot restart ketika:
   - mengubah isi `main()` atau inisialisasi yang hanya dijalankan sekali, seperti `initState()`;
   - mengubah *initializer* variabel global atau field `static`, karena nilainya sudah terlanjur dibuat;
   - mengubah struktur tipe secara besar, misalnya mengganti `StatelessWidget` menjadi `StatefulWidget` atau mengubah definisi enum dan generic class;
   - state lama membuat tampilan tidak sesuai dengan kode baru.

   **Full restart** diperlukan ketika perubahan berada di luar kode Dart, misalnya menambah dependensi di `pubspec.yaml` yang memiliki kode native (plugin), mengubah kode native Android/iOS, mengubah konfigurasi seperti `AndroidManifest.xml` atau `Info.plist`, atau menambah aset baru yang belum terdaftar.

### Tugas 8

1. **`Navigator.push()`, `Navigator.pushReplacement()`, dan `Navigator.pop()`**

   `Navigator` menyimpan halaman-halaman (*route*) dalam sebuah tumpukan (*stack*). Halaman yang tampil adalah halaman paling atas.
   - **`push()`** menaruh halaman baru di atas tumpukan. Halaman sebelumnya tetap ada di bawahnya, jadi pengguna bisa kembali ke sana.
   - **`pushReplacement()`** menaruh halaman baru sekaligus membuang halaman yang sedang tampil. Tinggi tumpukan tidak bertambah, dan halaman lama tidak bisa dikembalikan dengan tombol back.
   - **`pop()`** membuang halaman paling atas sehingga halaman di bawahnya tampil lagi. Metode ini juga dipakai untuk menutup dialog, karena dialog juga merupakan sebuah route.

   **Kartu aksi** "Tambah Edukasi" membuka formulir dengan `Navigator.push()` (lihat `_destinationFor()` di `lib/widgets/project_card.dart`). Tumpukannya menjadi `[MyHomePage, EducationFormPage]`, sehingga tombol back bawaan perangkat menjalankan `pop()` dan membawa pengguna kembali ke halaman utama. Tombol **OK** pada dialog ringkasan juga memakai `Navigator.pop(context)` untuk menutup dialog dan kembali ke formulir.

   **Opsi Home di drawer** memakai `Navigator.pushReplacement()` dengan `MyHomePage` sebagai halaman baru. Jika drawer dibuka dari formulir edukasi, halaman formulir diganti dengan halaman utama yang baru. Semua opsi drawer memakai `pushReplacement()` supaya tumpukan tidak terus bertambah ketika pengguna berpindah-pindah halaman lewat drawer. Ini juga membuat opsi Home tetap berfungsi di Chrome, yang tidak punya tombol back perangkat.

2. **Peran `Scaffold`, `AppBar`, dan `Drawer` untuk struktur yang konsisten**

   `Scaffold` menyediakan "slot" yang sama untuk setiap halaman: `appBar` di atas, `drawer` di kiri, dan `body` di tengah. Karena halaman utama, formulir proyek, dan formulir edukasi sama-sama dibangun di atas `Scaffold`, ketiganya punya kerangka yang identik. Yang berbeda hanya isi `body`. `AppBar` memberi judul halaman di posisi yang sama, dan karena `Scaffold` memiliki `drawer`, `AppBar` otomatis menampilkan ikon menu (hamburger) untuk membukanya.

   Drawer ditulis sekali sebagai widget `LeftDrawer` di `lib/widgets/left_drawer.dart`, lalu dipasang di ketiga halaman dengan `drawer: const LeftDrawer()`. Jadi, menambah opsi **Add Education** cukup dilakukan di satu tempat dan langsung muncul di semua halaman.

   **Contoh warna tema di lebih dari satu halaman:** warna indigo dipakai sebagai warna utama portofolio. `MaterialApp` di `main.dart` memakai `ColorScheme.fromSeed(seedColor: Colors.indigo)`. Halaman utama mengambil warna `AppBar` dari `Theme.of(context).colorScheme.primary`, sedangkan formulir proyek dan formulir edukasi memakai `Colors.indigo` untuk `AppBar` dan tombol **Simpan**. Header `LeftDrawer` juga berwarna indigo, sehingga drawer terlihat menyatu di halaman mana pun ia dibuka.

3. **Alasan tata letak formulir serta peran widget pengatur jarak dan penggulir**

   Formulir edukasi disusun sebagai satu `Column` vertikal, dengan satu input per baris dan tombol **Simpan** di bagian bawah. Susunan ini paling mudah diikuti di layar ponsel yang sempit: pengguna mengisi dari atas ke bawah tanpa perlu menggeser ke samping. Pengecualiannya adalah tanggal mulai dan tanggal selesai, yang diletakkan berdampingan dalam satu `Row` dengan dua `Expanded`. Keduanya adalah pasangan yang saling berkaitan, dan field tanggal cukup pendek sehingga muat di setengah lebar layar. Karena field-nya jadi lebih sempit, pesan error diizinkan tampil sampai dua baris (`errorMaxLines: 2`) agar tidak terpotong.

   - **Widget pengatur jarak.** Setiap input dibungkus `Padding(EdgeInsets.all(8.0))` sehingga jarak antar-field seragam dan pesan error tidak menempel ke field di bawahnya. `SizedBox(width: 8)` memberi celah di antara kedua field tanggal, sedangkan `Expanded` membagi lebar baris secara rata untuk keduanya.
   - **Widget penggulir.** Seluruh isi formulir dibungkus `SingleChildScrollView`. Saat papan ketik muncul, `Scaffold` memperkecil area `body`, sehingga enam input ditambah tombol **Simpan** bisa tidak muat. Tanpa penggulir, `Column` akan *overflow* (muncul garis kuning-hitam) dan tombol **Simpan** tidak bisa dijangkau. Dengan `SingleChildScrollView`, pengguna cukup menggulir untuk mencapai input atau tombol mana pun. Prinsip yang sama juga saya terapkan di halaman utama: setelah kartu keempat ditambahkan, kisi tombol menjadi dua baris dan sempat *overflow* di layar pendek, sehingga body halaman utama juga dibungkus `SingleChildScrollView`.

4. **Peran `GlobalKey<FormState>`, `validator`, dan `validate()`**

   - **`GlobalKey<FormState>`** (`_formKey`) dipasang di widget `Form`. Dari tombol **Simpan**, yang posisinya bukan ancestor dari field-field formulir, kunci ini memberi akses ke `FormState` lewat `_formKey.currentState`.
   - **`validator`** adalah fungsi milik setiap field yang menerima nilai field dan mengembalikan `null` jika valid, atau sebuah pesan error jika tidak valid. Pesan inilah yang tampil di bawah field terkait. Di `education_form.dart`, logika validator dipisahkan ke fungsi tersendiri seperti `_validateRequiredText()`, `_validateEndDate()`, dan `_validateDescription()`.
   - **`validate()`** dipanggil saat tombol **Simpan** ditekan. `FormState` menjalankan validator semua field sekaligus, menampilkan pesan error pada field yang gagal, lalu mengembalikan `true` hanya jika semuanya lolos. Dialog ringkasan hanya dibuka di dalam `if (_formKey.currentState!.validate())`, jadi dialog tidak pernah tampil selama masih ada input yang tidak valid.

   **Contoh nilai yang ditolak:** nama institusi yang hanya berisi spasi, misalnya `"     "`. Nilai ini tidak kosong secara teknis, karena panjang string-nya lebih dari nol, jadi pengecekan `value.isEmpty` saja akan meloloskannya. Validator memakai `value.trim().isEmpty` sehingga nilai itu ditolak dengan pesan "Nama institusi tidak boleh kosong!". Contoh lain adalah tanggal selesai 10 Juni untuk tanggal mulai 20 Juni. Kedua tanggal berasal dari `showDatePicker()`, jadi formatnya pasti benar, tetapi urutannya salah sehingga ditolak dengan pesan "Tidak boleh sebelum tanggal mulai!".

   **Mengapa memilih jenis input atau papan ketik saja belum cukup:** jenis input hanya membatasi *bentuk* data, bukan *makna* atau aturan bisnisnya. `keyboardType: TextInputType.url` hanya mengganti tata letak papan ketik, sementara pengguna tetap bisa mengetik atau menempelkan teks apa saja, termasuk lewat papan ketik fisik di Chrome. Date picker menjamin setiap tanggal valid, tetapi tidak tahu bahwa tanggal selesai harus setelah tanggal mulai, karena aturan itu melibatkan dua field sekaligus. Begitu pula `TextFormField` tidak bisa mencegah isian yang hanya berisi spasi. Karena itu, aturan seperti wajib diisi, batas panjang, dan urutan tanggal tetap harus diperiksa oleh `validator`.