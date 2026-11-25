import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

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
/// menampilkan SnackBar lalu menjalankan aksinya:
/// - "Lihat Proyek" membuka daftar proyek (publik, tanpa login).
/// - "Tambah Proyek" dilindungi [ensureLoggedIn] sebelum membuka form.
/// - "Tambah Edukasi" membuka form edukasi.
/// - "Logout" mencabut token lewat [AuthState.logout].
class ItemCard extends StatelessWidget {
  /// Data tombol yang ditampilkan oleh kartu ini.
  final ItemHomepage item;

  /// Membuat [ItemCard] dari [item].
  const ItemCard(this.item, {super.key});

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _onTap(BuildContext context) async {
    switch (item.name) {
      case "Logout":
        final auth = context.read<AuthState>();
        if (!auth.isLoggedIn) {
          _showSnackBar(context, "Kamu belum login.");
          return;
        }
        await auth.logout();
        if (!context.mounted) return;
        _showSnackBar(context, "Berhasil logout.");
        return;
      case "Tambah Proyek":
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
        // Form tambah proyek hanya dapat dibuka setelah login.
        if (!await ensureLoggedIn(context) || !context.mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProjectFormPage()),
        );
        return;
      case "Lihat Proyek":
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProjectListPage()),
        );
        return;
      case "Tambah Edukasi":
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EducationFormPage()),
        );
        return;
      default:
        _showSnackBar(context, "Kamu telah menekan tombol ${item.name}!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      // Menggunakan warna unik milik masing-masing item sebagai latar kartu.
      color: item.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _onTap(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30.0),
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
