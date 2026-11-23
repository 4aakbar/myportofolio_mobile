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

  String _level = "S1"; // default
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

  /// Dekorasi input yang seragam untuk semua field formulir.
  InputDecoration _inputDecoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? label,
      suffixIcon: suffix,
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
                      _formKey.currentState!.validate();
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
