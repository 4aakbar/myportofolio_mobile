import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';

/// Model data untuk satu tombol aksi pada halaman utama.
class ItemHomepage {
  /// Nama tombol yang ditampilkan pada kartu dan pesan SnackBar.
  final String name;

  /// Ikon yang ditampilkan di atas nama tombol.
  final IconData icon;

  /// Warna latar kartu tombol.
  final Color color;

  /// Membuat [ItemHomepage] dengan [name], [icon], dan [color].
  ItemHomepage(this.name, this.icon, this.color);
}

/// Kartu tombol aksi yang dirender dari sebuah [ItemHomepage].
///
/// Kartu diberi warna latar [ItemHomepage.color]. Ketika ditekan, kartu
/// menampilkan SnackBar berisi "Kamu telah menekan tombol [nama]!" dan,
/// untuk tombol yang memiliki halaman tujuan, berpindah ke halaman tersebut
/// (lihat [_destinationFor]).
class ItemCard extends StatelessWidget {
  /// Data tombol yang ditampilkan oleh kartu ini.
  final ItemHomepage item;

  /// Membuat [ItemCard] dari [item].
  const ItemCard(this.item, {super.key});

  /// Mengembalikan halaman tujuan untuk [name], atau `null` jika tombol
  /// tersebut belum memiliki halaman (misalnya "Lihat Proyek" dan "Logout").
  static Widget? _destinationFor(String name) {
    switch (name) {
      case "Tambah Proyek":
        return const ProjectFormPage();
      case "Tambah Edukasi":
        return const EducationFormPage();
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Menggunakan warna unik milik masing-masing item sebagai latar kartu.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        // Aksi ketika kartu ditekan oleh pengguna.
        onTap: () {
          // Menampilkan SnackBar dengan pesan interaktif.
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text("Kamu telah menekan tombol ${item.name}!")),
            );

          // Navigasi ke halaman yang sesuai. push() dipakai agar pengguna
          // dapat kembali ke menu dengan tombol Back.
          final destination = _destinationFor(item.name);
          if (destination != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
