import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
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

    expect(find.byType(ItemCard), findsNWidgets(3));

    Color colorOf(String name) {
      final material = tester.widget<Material>(find.ancestor(
        of: find.text(name),
        matching: find.byType(Material),
      ).first);
      return material.color!;
    }

    expect(colorOf('Lihat Proyek'), Colors.blue);
    expect(colorOf('Tambah Proyek'), Colors.green);
    expect(colorOf('Logout'), Colors.red);
  });

  testWidgets('Menekan tombol menampilkan SnackBar sesuai nama tombol',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // "Tambah Proyek" berpindah halaman, sehingga diuji terpisah di bawah.
    for (final name in ['Lihat Proyek', 'Logout']) {
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
}
