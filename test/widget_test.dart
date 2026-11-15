import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

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

    for (final name in ['Lihat Proyek', 'Tambah Proyek', 'Logout']) {
      await tester.tap(find.text(name));
      await tester.pump();

      expect(find.text('Kamu telah menekan tombol $name!'), findsOneWidget);
    }
  });
}
