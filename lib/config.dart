/// Base URL backend Django REST Framework.
///
/// Default-nya `http://10.0.2.2:8000`, yaitu alamat mesin pengembangan lokal
/// jika dilihat dari emulator Android. Timpa dengan
/// `--dart-define=API_BASE_URL=http://localhost:8000` saat menjalankan di
/// Chrome, atau dengan URL hasil deploy (tanpa `/` di akhir).
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
