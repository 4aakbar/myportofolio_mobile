import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/login.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_detail.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';
import 'package:provider/provider.dart';

const _projectJson = {
  'id': '7c6f2a52-6a4f-4c5d-9a57-0f7a1a8f9b10',
  'title': 'Veto',
  'description': 'Sistem kepatuhan logistik',
  'category': 'ai',
  'category_display': 'AI/ML',
  'link': 'https://github.com/example/veto',
  'created_at': '2026-11-20T10:00:00Z',
  'star_count': 3,
  'is_starred': false,
};

/// Backend palsu yang meniru endpoint DRF dan mencatat request yang masuk.
class FakeBackend {
  final requests = <http.Request>[];
  List<Map<String, dynamic>> projects = [Map.of(_projectJson)];
  final String validToken = 'token-123';
  bool tokenRevoked = false;

  late final MockClient client = MockClient((request) async {
    requests.add(request);
    final path = request.url.path;
    final auth = request.headers['Authorization'];
    final tokenOk = auth == 'Token $validToken' && !tokenRevoked;

    if (path == '/api/v1/auth/token/' && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['username'] == 'owner' && body['password'] == 'secret') {
        tokenRevoked = false;
        return http.Response(jsonEncode({'token': validToken}), 200);
      }
      return http.Response('{"non_field_errors":["bad"]}', 400);
    }
    if (path == '/api/v1/auth/logout/' && request.method == 'POST') {
      if (!tokenOk) return http.Response('', 401);
      tokenRevoked = true;
      return http.Response('', 204);
    }
    if (path == '/api/v1/projects/' && request.method == 'GET') {
      return http.Response(jsonEncode(projects), 200);
    }
    if (path == '/api/v1/projects/' && request.method == 'POST') {
      if (!tokenOk) return http.Response('{"detail":"Invalid token."}', 401);
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final created = {
        ...body,
        'id': 'new-id',
        'category_display': Project.categories[body['category']],
        'created_at': '2026-11-25T10:00:00Z',
        'star_count': 0,
        'is_starred': false,
      };
      projects.add(created);
      return http.Response(jsonEncode(created), 201);
    }
    return http.Response('Not found', 404);
  });

  late final ApiClient apiClient = ApiClient(
    client: client,
    baseUrl: 'http://test',
  );
}

/// Membungkus [child] dengan provider yang sama seperti [MyApp].
Widget wrapWithProviders(Widget child, FakeBackend backend, {String? token}) {
  return MultiProvider(
    providers: [
      Provider.value(value: backend.apiClient),
      ChangeNotifierProvider(
        create: (_) => AuthState(backend.apiClient, initialToken: token),
      ),
    ],
    child: MaterialApp(home: child),
  );
}

/// Mengisi form login dan menekan tombol Login.
Future<void> fillLogin(
  WidgetTester tester,
  String username,
  String password,
) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), username);
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeBackend backend;

  setUp(() {
    backend = FakeBackend();
  });

  testWidgets('Halaman menu menampilkan identitas pemilik portofolio', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
    expect(find.text('2506613590'), findsOneWidget);
    expect(find.text('Andy Aulia Akbar'), findsOneWidget);
    expect(find.text('PBP C'), findsOneWidget);
  });

  testWidgets('Setiap ItemCard memiliki warna latar yang berbeda', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    expect(find.byType(ItemCard), findsNWidgets(4));

    Color colorOf(String name) {
      final material = tester.widget<Material>(
        find
            .ancestor(of: find.text(name), matching: find.byType(Material))
            .first,
      );
      return material.color!;
    }

    expect(colorOf('Lihat Proyek'), Colors.blue);
    expect(colorOf('Tambah Proyek'), Colors.green);
    expect(colorOf('Tambah Edukasi'), Colors.orange);
    expect(colorOf('Logout'), Colors.red);
  });

  testWidgets('Kartu Lihat Proyek menampilkan SnackBar dan daftar proyek', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    await tester.tap(find.text('Lihat Proyek'));
    await tester.pump();
    expect(
      find.text('Kamu telah menekan tombol Lihat Proyek!'),
      findsOneWidget,
    );

    await tester.pumpAndSettle();
    expect(find.byType(ProjectListPage), findsOneWidget);
    expect(find.text('Veto'), findsOneWidget);
  });

  testWidgets('Kartu Logout saat belum login menampilkan pesan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pump();

    expect(find.text('Kamu belum login.'), findsOneWidget);
    expect(backend.requests, isEmpty);
  });

  testWidgets('Kartu Logout saat sudah login mencabut token', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(MyHomePage(), backend, token: 'token-123'),
    );

    await tester.ensureVisible(find.text('Logout'));
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Berhasil logout.'), findsOneWidget);
    expect(backend.tokenRevoked, isTrue);
  });

  testWidgets('Tambah Proyek saat belum login membuka halaman Login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);

    // Login berhasil langsung melanjutkan ke form tambah proyek.
    await fillLogin(tester, 'owner', 'secret');

    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(ProjectFormPage), findsOneWidget);
    expect(find.text('Add Project Form'), findsOneWidget);

    // Form memiliki drawer sehingga tidak ada panah back di AppBar;
    // simulasikan tombol Back sistem perangkat.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  testWidgets('Membatalkan login tidak membuka form tambah proyek', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(MyHomePage), findsOneWidget);
    expect(find.byType(ProjectFormPage), findsNothing);
  });

  testWidgets('Tambah Proyek saat sudah login langsung membuka form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrapWithProviders(MyHomePage(), backend, token: 'token-123'),
    );

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(ProjectFormPage), findsOneWidget);
  });

  testWidgets('Login memvalidasi input dan menolak kredensial salah', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrapWithProviders(const LoginPage(), backend));

    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await tester.pump();
    expect(find.text('Username cannot be empty!'), findsOneWidget);
    expect(find.text('Password cannot be empty!'), findsOneWidget);
    expect(backend.requests, isEmpty);

    await fillLogin(tester, 'owner', 'salah');

    expect(find.textContaining('status 400'), findsOneWidget);
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('Drawer menampilkan navigasi dan melindungi Add Project', (
    WidgetTester tester,
  ) async {
    // Font uji (Ahem) menggambar tiap huruf sebagai kotak penuh sehingga teks
    // header jauh lebih lebar daripada di perangkat asli; skala diperkecil
    // agar DrawerHeader tidak overflow di lingkungan uji.
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    Finder inDrawer(String text) =>
        find.descendant(of: find.byType(Drawer), matching: find.text(text));

    await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();

    expect(find.text('My Portfolio'), findsOneWidget);
    expect(
      find.text('Explore personal projects and experiences!'),
      findsOneWidget,
    );

    // Belum login: opsi Login tampil dan Add Project meminta login.
    expect(inDrawer('Login'), findsOneWidget);
    expect(inDrawer('Logout'), findsNothing);

    await tester.tap(find.text('Add Project'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    await fillLogin(tester, 'owner', 'secret');
    expect(find.byType(ProjectFormPage), findsOneWidget);

    // Sudah login: opsi Logout menggantikan Login.
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(inDrawer('Login'), findsNothing);
    expect(inDrawer('Logout'), findsOneWidget);

    await tester.tap(inDrawer('Logout'));
    await tester.pumpAndSettle();
    expect(find.text('Berhasil logout.'), findsOneWidget);
    expect(backend.tokenRevoked, isTrue);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    expect(inDrawer('Login'), findsOneWidget);

    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectListPage), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byType(MyHomePage), findsOneWidget);
  });

  group('Daftar dan detail proyek', () {
    testWidgets('Menampilkan proyek dari API tanpa login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const ProjectListPage(), backend),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Veto'), findsOneWidget);
      expect(find.text('AI/ML'), findsOneWidget);
      expect(find.text('Sistem kepatuhan logistik'), findsOneWidget);
      expect(backend.requests.single.headers['Authorization'], isNull);

      await tester.tap(find.text('Veto'));
      await tester.pumpAndSettle();

      expect(find.byType(ProjectDetailPage), findsOneWidget);
      expect(find.text('https://github.com/example/veto'), findsOneWidget);
      expect(find.text('3 star'), findsOneWidget);
    });

    testWidgets('Daftar kosong menampilkan pesan', (WidgetTester tester) async {
      backend.projects = [];
      await tester.pumpWidget(
        wrapWithProviders(const ProjectListPage(), backend),
      );
      await tester.pumpAndSettle();

      expect(find.text('No projects found.'), findsOneWidget);
    });

    testWidgets('Error server menampilkan tombol Retry', (
      WidgetTester tester,
    ) async {
      final failing = ApiClient(
        client: MockClient((_) async => http.Response('boom', 500)),
        baseUrl: 'http://test',
      );
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: failing),
            ChangeNotifierProvider(create: (_) => AuthState(failing)),
          ],
          child: const MaterialApp(home: ProjectListPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('status 500'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Detail tanpa link tidak menampilkan bagian tautan', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ProjectDetailPage(
            project: Project(title: 'Tanpa Link', description: 'Deskripsi'),
          ),
        ),
      );

      expect(find.text('Tautan Proyek'), findsNothing);
      expect(find.text('Other'), findsOneWidget);
    });
  });

  group('Formulir proyek', () {
    testWidgets('Menolak field wajib kosong dan URL tidak valid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const ProjectFormPage(), backend, token: 'token-123'),
      );

      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Title tidak boleh kosong!'), findsOneWidget);
      expect(find.text('Description tidak boleh kosong!'), findsOneWidget);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(2), 'bukan-url');
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.textContaining('URL yang valid'), findsOneWidget);
      expect(backend.requests, isEmpty);
    });

    testWidgets('Data valid dikirim dengan token dan menampilkan konfirmasi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const ProjectFormPage(), backend, token: 'token-123'),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'MyPortfolio Mobile');
      await tester.enterText(fields.at(1), 'Aplikasi Flutter');
      await tester.enterText(fields.at(2), 'https://example.com');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final request = backend.requests.single;
      expect(request.method, 'POST');
      expect(request.headers['Authorization'], 'Token token-123');
      expect(jsonDecode(request.body), {
        'title': 'MyPortfolio Mobile',
        'description': 'Aplikasi Flutter',
        'category': 'web',
        'link': 'https://example.com',
      });

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Proyek berhasil ditambahkan!'), findsOneWidget);
      expect(find.text('Title: MyPortfolio Mobile'), findsOneWidget);
      expect(find.text('Category: Web Application'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Token tidak valid (401) membuat logout dan meminta login', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(
          const ProjectFormPage(),
          backend,
          token: 'kedaluwarsa',
        ),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Judul');
      await tester.enterText(fields.at(1), 'Deskripsi');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
      final context = tester.element(find.byType(LoginPage));
      expect(context.read<AuthState>().isLoggedIn, isFalse);
    });
  });

  group('AuthState', () {
    test('login menyimpan token dan logout mencabutnya di server', () async {
      final auth = AuthState(backend.apiClient);
      var notified = 0;
      auth.addListener(() => notified++);

      await auth.login('owner', 'secret');
      expect(auth.token, 'token-123');
      expect(auth.isLoggedIn, isTrue);

      await auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(backend.tokenRevoked, isTrue);
      expect(notified, 2);
    });

    test('logout tetap menghapus token lokal walau server menolak', () async {
      final auth = AuthState(backend.apiClient, initialToken: 'kedaluwarsa');

      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
    });

    test('login gagal melempar ApiException', () async {
      final auth = AuthState(backend.apiClient);

      await expectLater(
        auth.login('owner', 'salah'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)),
      );
      expect(auth.isLoggedIn, isFalse);
    });
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

    testWidgets('Kartu Tambah Edukasi membuka form dan Back kembali ke menu', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

      await tester.ensureVisible(find.text('Tambah Edukasi'));
      await tester.tap(find.text('Tambah Edukasi'));
      await tester.pumpAndSettle();

      expect(find.byType(EducationFormPage), findsOneWidget);
      expect(find.text('Add Education Form'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(EducationFormPage), findsNothing);
    });

    testWidgets('Drawer membuka form edukasi dan Home kembali ke menu', (
      WidgetTester tester,
    ) async {
      // Lihat catatan font uji pada test drawer di atas.
      tester.platformDispatcher.textScaleFactorTestValue = 0.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(MyApp(apiClient: backend.apiClient));

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();

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

    testWidgets('Input kosong, hanya spasi, atau terlalu panjang ditolak', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const EducationFormPage(), backend),
      );

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

    testWidgets('Tanggal selesai sebelum tanggal mulai ditolak', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const EducationFormPage(), backend),
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Universitas Indonesia');
      await tester.enterText(fields.at(1), 'Ilmu Komputer');
      await pickDate(tester, 'Tanggal Mulai', 20);
      await pickDate(tester, 'Tanggal Selesai', 10);
      await tapSave(tester);

      expect(find.text('Tidak boleh sebelum tanggal mulai!'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Input valid menampilkan ringkasan dan OK kembali ke form', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        wrapWithProviders(const EducationFormPage(), backend),
      );

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
        find.text('Tanggal Selesai: ${dateThisMonth(25)}'),
        findsOneWidget,
      );
      expect(find.text('Deskripsi: Asisten dosen PBP'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(EducationFormPage), findsOneWidget);
    });
  });
}
