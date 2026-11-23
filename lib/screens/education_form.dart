import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan riwayat edukasi ke portofolio.
///
/// Dibuat sebagai [StatefulWidget] karena isian setiap field (termasuk
/// tanggal yang dipilih lewat [showDatePicker]) disimpan pada state halaman.
/// [Form] diakses melalui [GlobalKey<FormState>] untuk validasi.
class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  /// Kunci untuk mengakses state [Form], melakukan validasi, dan reset.
  final _formKey = GlobalKey<FormState>();

  String _institution = "";
  String _level = "S1"; // default
  String _major = "";
  String _description = "";
  DateTime? _startDate;
  DateTime? _endDate;

  /// Controller untuk menampilkan tanggal terpilih pada field read-only.
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  final List<String> _levels = [
    'SMA/SMK',
    'D3',
    'S1',
    'S2',
    'S3',
    'Kursus/Bootcamp',
  ];

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Memformat [DateTime] menjadi `dd/mm/yyyy` untuk ditampilkan.
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  /// Batas panjang nama institusi dan jurusan.
  static const int _maxNameLength = 100;

  /// Batas panjang deskripsi.
  static const int _maxDescriptionLength = 500;

  /// Validator untuk field teks wajib dengan batas panjang [maxLength].
  ///
  /// Menolak nilai kosong atau yang hanya berisi spasi, serta nilai yang
  /// melebihi [maxLength] karakter setelah spasi di awal/akhir dibuang.
  static String? _validateRequiredText(
    String? value, {
    required String fieldName,
    required int maxLength,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return "$fieldName tidak boleh kosong!";
    }
    if (trimmed.length > maxLength) {
      return "$fieldName maksimal $maxLength karakter!";
    }
    return null;
  }

  /// Validator tanggal mulai: wajib diisi.
  String? _validateStartDate(String? _) {
    if (_startDate == null) {
      return "Pilih tanggal mulai!";
    }
    return null;
  }

  /// Validator tanggal selesai: wajib diisi dan tidak boleh lebih awal
  /// dari tanggal mulai.
  String? _validateEndDate(String? _) {
    if (_endDate == null) {
      return "Pilih tanggal selesai!";
    }
    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      return "Tidak boleh sebelum tanggal mulai!";
    }
    return null;
  }

  /// Validator deskripsi: opsional, tetapi dibatasi panjangnya.
  static String? _validateDescription(String? value) {
    if ((value?.trim().length ?? 0) > _maxDescriptionLength) {
      return "Deskripsi maksimal $_maxDescriptionLength karakter!";
    }
    return null;
  }

  /// Membuka [showDatePicker] dan menyimpan tanggal terpilih ke state.
  ///
  /// [isStart] menentukan apakah tanggal yang dipilih adalah tanggal mulai
  /// atau tanggal selesai.
  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _startDate : _endDate) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1950),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
      } else {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  /// Menampilkan ringkasan seluruh isian formulir dalam [AlertDialog].
  ///
  /// Hanya dipanggil setelah [FormState.validate] mengembalikan `true`,
  /// sehingga [_startDate] dan [_endDate] dijamin sudah terisi. Tombol OK
  /// menutup dialog dan mengembalikan pengguna ke formulir.
  void _showSummaryDialog() {
    final description = _description.trim();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edukasi berhasil disimpan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Institusi: ${_institution.trim()}'),
                Text('Jenjang: $_level'),
                Text('Jurusan: ${_major.trim()}'),
                Text('Tanggal Mulai: ${_formatDate(_startDate!)}'),
                Text('Tanggal Selesai: ${_formatDate(_endDate!)}'),
                Text('Deskripsi: ${description.isEmpty ? '-' : description}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  /// Dekorasi input yang seragam untuk semua field formulir.
  InputDecoration _inputDecoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? label,
      suffixIcon: suffix,
      // Pesan kesalahan boleh dua baris agar tidak terpotong pada
      // field tanggal yang lebarnya hanya setengah layar.
      errorMaxLines: 2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Add Education Form',
          ),
        ),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SingleChildScrollView menjaga semua input dan tombol Simpan tetap
        // dapat dijangkau pada layar sempit atau saat papan ketik tampil.
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Institution ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _inputDecoration(
                    "Nama Institusi",
                    hint: "Contoh: Universitas Indonesia",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _institution = value!;
                    });
                  },
                  validator: (value) => _validateRequiredText(
                    value,
                    fieldName: "Nama institusi",
                    maxLength: _maxNameLength,
                  ),
                ),
              ),

              // === Level ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: _inputDecoration("Jenjang Pendidikan"),
                  initialValue: _level,
                  items: _levels
                      .map((level) => DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _level = newValue!;
                    });
                  },
                ),
              ),

              // === Major ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _inputDecoration(
                    "Jurusan / Bidang Studi",
                    hint: "Contoh: Ilmu Komputer",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _major = value!;
                    });
                  },
                  validator: (value) => _validateRequiredText(
                    value,
                    fieldName: "Jurusan",
                    maxLength: _maxNameLength,
                  ),
                ),
              ),

              // === Start & End Date ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _startDateController,
                        readOnly: true,
                        decoration: _inputDecoration(
                          "Tanggal Mulai",
                          hint: "dd/mm/yyyy",
                          suffix: const Icon(Icons.calendar_today),
                        ),
                        onTap: () => _pickDate(isStart: true),
                        validator: _validateStartDate,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _endDateController,
                        readOnly: true,
                        decoration: _inputDecoration(
                          "Tanggal Selesai",
                          hint: "dd/mm/yyyy",
                          suffix: const Icon(Icons.calendar_today),
                        ),
                        onTap: () => _pickDate(isStart: false),
                        validator: _validateEndDate,
                      ),
                    ),
                  ],
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 4,
                  decoration: _inputDecoration(
                    "Deskripsi (opsional)",
                    hint: "Aktivitas, prestasi, atau mata kuliah relevan",
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _description = value!;
                    });
                  },
                  validator: _validateDescription,
                ),
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: () {
                      // Dialog ringkasan hanya tampil bila semua input valid;
                      // jika tidak, pesan kesalahan muncul di field terkait.
                      if (_formKey.currentState!.validate()) {
                        _showSummaryDialog();
                      }
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
