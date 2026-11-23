import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

void main() {
  testWidgets('Halaman menu menampilkan identitas pemilik portofolio',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text('2506613590'), findsOneWidget);
    expect(find.text('Andy Aulia Akbar'), findsOneWidget);
    expect(find.text('PBP C'), findsOneWidget);
  });

  testWidgets('Setiap ItemCard memiliki warna latar yang berbeda',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(ItemCard), findsNWidgets(4));

    Color colorOf(String name) {
      final material = tester.widget<Material>(find.ancestor(
        of: find.text(name),
        matching: find.byType(Material),
      ).first);
      return material.color!;
    }

    expect(colorOf('Lihat Proyek'), Colors.blue);
    expect(colorOf('Tambah Proyek'), Colors.green);
    expect(colorOf('Tambah Edukasi'), Colors.orange);
    expect(colorOf('Logout'), Colors.red);
  });

  testWidgets('Menekan tombol menampilkan SnackBar sesuai nama tombol',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // "Tambah Proyek" dan "Tambah Edukasi" berpindah halaman, sehingga diuji terpisah di bawah.
    for (final name in ['Lihat Proyek', 'Logout']) {
      // Kartu baris kedua bisa berada di luar layar uji, jadi digulir dulu.
      await tester.ensureVisible(find.text(name));
      await tester.tap(find.text(name));
      await tester.pump();

      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    }
  });

  testWidgets('Tombol Tambah Proyek membuka form dan Back kembali ke menu',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);

    // Halaman form memiliki drawer, sehingga AppBar menampilkan ikon menu
    // alih-alih panah back. Simulasikan tombol Back sistem perangkat.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('Drawer berisi header serta navigasi Home dan Add Project',
      (WidgetTester tester) async {
    // Font uji (Ahem) menggambar tiap huruf sebagai kotak penuh sehingga teks
    // header jauh lebih lebar daripada di perangkat asli; skala diperkecil
    // agar DrawerHeader tidak overflow di lingkungan uji.
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('My Portfolio'), findsOneWidget);
    expect(find.text('Explore personal projects and experiences!'),
        findsOneWidget);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectFormPage), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('Form menolak field wajib kosong dan menampilkan data valid',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProjectFormPage()));

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Nama proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.text('Deskripsi proyek tidak boleh kosong!'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'MyPortfolio');
    await tester.enterText(fields.at(1), 'Aplikasi portofolio pribadi');
    await tester.enterText(fields.at(2), 'Flutter, Django');
    await tester.enterText(fields.at(3), 'https://example.com');

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
    expect(find.text('Nama Proyek: MyPortfolio'), findsOneWidget);
    expect(find.text('Deskripsi: Aplikasi portofolio pribadi'), findsOneWidget);
    expect(find.text('Kategori: Web Development'), findsOneWidget);
    expect(find.text('Teknologi: Flutter, Django'), findsOneWidget);
    expect(find.text('Tautan: https://example.com'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  group('Formulir Edukasi', () {
    /// Membuka date picker dari field [label], memilih hari [day] pada bulan
    /// yang sedang tampil, lalu menekan OK.
    Future<void> pickDate(WidgetTester tester, String label, int day) async {
      await tester.tap(find.widgetWithText(TextFormField, label));
      await tester.pumpAndSettle();
      await tester.tap(find.text('$day'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    /// Menekan tombol Simpan (digulir dulu bila berada di luar layar).
    Future<void> tapSave(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Simpan'));
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();
    }

    /// Format tanggal yang sama dengan formulir: dd/mm/yyyy pada bulan ini.
    String dateThisMonth(int day) {
      final now = DateTime.now();
      final dd = day.toString().padLeft(2, '0');
      final mm = now.month.toString().padLeft(2, '0');
      return '$dd/$mm/${now.year}';
    }

    testWidgets('Kartu Tambah Edukasi membuka form dan Back kembali ke menu',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.ensureVisible(find.text('Tambah Edukasi'));
      await tester.tap(find.text('Tambah Edukasi'));
      await tester.pumpAndSettle();

      expect(find.byType(EducationFormPage), findsOneWidget);
      expect(find.text('Add Education Form'), findsOneWidget);

      // Form memiliki drawer sehingga tidak ada panah back di AppBar;
      // simulasikan tombol Back sistem perangkat.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(EducationFormPage), findsNothing);
    });

    testWidgets('Drawer membuka form edukasi dan Home kembali ke menu',
        (WidgetTester tester) async {
      // Lihat catatan font uji pada test drawer di atas.
      tester.platformDispatcher.textScaleFactorTestValue = 0.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

      // Opsi lama tetap ada di samping opsi baru.
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      expect(find.text('Add Education'), findsOneWidget);

      await tester.tap(find.text('Add Education'));
      await tester.pumpAndSettle();
      expect(find.byType(EducationFormPage), findsOneWidget);

      // Drawer yang sama juga tersedia di halaman form edukasi.
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(find.text('Add Education'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(EducationFormPage), findsNothing);
    });

    testWidgets('Input kosong, hanya spasi, atau terlalu panjang ditolak',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

      await tapSave(tester);

      expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Jurusan tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Pilih tanggal mulai!'), findsOneWidget);
      expect(find.text('Pilih tanggal selesai!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '    ');
      await tester.enterText(fields.at(1), 'a' * 101);
      await tester.enterText(fields.at(4), 'a' * 501);
      await tapSave(tester);

      expect(find.text('Nama institusi tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Jurusan maksimal 100 karakter!'), findsOneWidget);
      expect(find.text('Deskripsi maksimal 500 karakter!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Tanggal selesai sebelum tanggal mulai ditolak',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Universitas Indonesia');
      await tester.enterText(fields.at(1), 'Ilmu Komputer');
      await pickDate(tester, 'Tanggal Mulai', 20);
      await pickDate(tester, 'Tanggal Selesai', 10);
      await tapSave(tester);

      expect(find.text('Tidak boleh sebelum tanggal mulai!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Input valid menampilkan ringkasan dan OK kembali ke form',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: EducationFormPage()));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '  Universitas Indonesia  ');
      await tester.enterText(fields.at(1), 'Ilmu Komputer');
      await pickDate(tester, 'Tanggal Mulai', 10);
      await pickDate(tester, 'Tanggal Selesai', 25);
      await tester.enterText(fields.at(4), 'Asisten dosen PBP');
      await tapSave(tester);

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Edukasi berhasil disimpan!'), findsOneWidget);
      // Spasi di awal dan akhir dibuang sebelum ditampilkan.
      expect(find.text('Institusi: Universitas Indonesia'), findsOneWidget);
      expect(find.text('Jenjang: S1'), findsOneWidget);
      expect(find.text('Jurusan: Ilmu Komputer'), findsOneWidget);
      expect(find.text('Tanggal Mulai: ${dateThisMonth(10)}'), findsOneWidget);
      expect(
          find.text('Tanggal Selesai: ${dateThisMonth(25)}'), findsOneWidget);
      expect(find.text('Deskripsi: Asisten dosen PBP'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(EducationFormPage), findsOneWidget);
    });
  });
}
