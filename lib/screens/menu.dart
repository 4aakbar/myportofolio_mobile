import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

/// Halaman utama aplikasi MyPortfolio Mobile.
///
/// Menampilkan identitas pemilik portofolio melalui tiga [InfoCard]
/// (NPM, nama, dan kelas) serta kisi tombol aksi berupa [ItemCard].
/// Dibuat sebagai [StatelessWidget] karena seluruh datanya statis dan
/// tidak berubah selama halaman ditampilkan.
class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  /// Nomor Pokok Mahasiswa pemilik portofolio.
  final String npm = "2506613590";

  /// Nama lengkap pemilik portofolio.
  final String nama = "Andy Aulia Akbar";

  /// Kelas mata kuliah PBP pemilik portofolio.
  final String kelas = "PBP C";

  /// Daftar tombol aksi yang ditampilkan pada kisi menu.
  ///
  /// Setiap item membawa nama, ikon, dan warna latarnya sendiri sehingga
  /// [ItemCard] tidak membutuhkan percabangan untuk menentukan warna.
  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Proyek", Icons.folder, Colors.blue),
    ItemHomepage("Tambah Proyek", Icons.add_circle, Colors.green),
    ItemHomepage("Logout", Icons.logout, Colors.red),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Drawer navigasi untuk berpindah antarhalaman.
      drawer: const LeftDrawer(),
      // Body halaman utama dengan padding di sekelilingnya.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InfoCard(title: 'NPM', content: npm),
                InfoCard(title: 'Name', content: nama),
                InfoCard(title: 'Class', content: kelas),
              ],
            ),

            const SizedBox(height: 16.0),

            // Bagian tengah: pesan sambutan dan kisi tombol menu portofolio.
            Center(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 16.0),
                    child: Text(
                      'Selamat datang di MyPortfolio Mobile!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                      ),
                    ),
                  ),

                  // GridView menampilkan kartu tombol dalam tata letak kisi 3 kolom.
                  GridView.count(
                    primary: true,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                    shrinkWrap: true,
                    children: items.map((ItemHomepage item) {
                      return ItemCard(item);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu informasi yang menampilkan sebuah judul dan isinya.
///
/// Digunakan di bagian atas [MyHomePage] untuk menampilkan identitas
/// pemilik portofolio, misalnya `InfoCard(title: 'NPM', content: npm)`.
class InfoCard extends StatelessWidget {
  /// Judul kartu yang ditampilkan dengan huruf tebal, misalnya "NPM".
  final String title;

  /// Isi kartu yang ditampilkan di bawah judul.
  final String content;

  /// Membuat [InfoCard] dengan [title] dan [content] yang wajib diisi.
  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        // Menyesuaikan lebar kartu dengan proporsi layar (dibagi 3.5).
        width: MediaQuery.of(context).size.width / 3.5,
        padding: const EdgeInsets.all(16.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(content),
          ],
        ),
      ),
    );
  }
}
