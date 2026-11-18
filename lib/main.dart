import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/screens/menu.dart';

/// Titik masuk aplikasi; menjalankan [MyApp] sebagai root widget.
void main() {
  runApp(const MyApp());
}

/// Root widget aplikasi MyPortfolio Mobile.
///
/// Mengatur [MaterialApp] beserta tema global (skema warna indigo dengan
/// warna sekunder amber) dan menjadikan [MyHomePage] sebagai halaman awal.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyPortfolio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          secondary: Colors.amber[700],
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
