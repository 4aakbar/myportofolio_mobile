import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Halaman formulir untuk menambahkan proyek baru ke portofolio.
///
/// Field mengikuti `ProjectSerializer` di backend: Title, Description,
/// Category, dan Project Link (opsional). Setelah lolos validasi, data
/// dikirim ke `POST /api/v1/projects/` dengan token milik pengguna.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  /// Kunci untuk mengakses state [Form], melakukan validasi, dan reset.
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _linkController = TextEditingController();
  String _category = 'web';
  bool _isSubmitting = false;

  /// Batas panjang judul sesuai `max_length` pada model Django.
  static const int _maxTitleLength = 255;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  static String? _validateTitle(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Title tidak boleh kosong!';
    if (trimmed.length > _maxTitleLength) {
      return 'Title maksimal $_maxTitleLength karakter!';
    }
    return null;
  }

  static String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Description tidak boleh kosong!';
    }
    return null;
  }

  /// Link opsional, tetapi bila diisi harus URL http/https yang valid.
  static String? _validateLink(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      return 'Masukkan URL yang valid (diawali http:// atau https://)!';
    }
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final loggedIn = await ensureLoggedIn(context);
    if (!mounted || !loggedIn) return;

    final auth = context.read<AuthState>();
    final token = auth.token;
    if (token == null) return;

    final newProject = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      link: _linkController.text.trim(),
    );

    setState(() {
      _isSubmitting = true;
    });

    try {
      final created = await context.read<ApiClient>().createProject(
        newProject,
        token: token,
      );
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      await _showSuccessDialog(created);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token kedaluwarsa/dicabut: logout lalu minta login ulang.
        await auth.logout();
        if (!mounted) return;
        _showSnackBar('Sesi berakhir, silakan login ulang.');
        final reLoggedIn = await ensureLoggedIn(context);
        if (reLoggedIn && mounted) {
          _showSnackBar('Login berhasil, tekan Save sekali lagi.');
        }
        return;
      }
      if (e.statusCode == 403) {
        _showSnackBar('Hanya pemilik portofolio yang dapat menambah proyek.');
      } else {
        _showSnackBar('Gagal menyimpan proyek (status ${e.statusCode}).');
      }
    } catch (_) {
      if (mounted) _showSnackBar('Tidak dapat terhubung ke server.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog(Project project) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Title: ${project.title}'),
                Text('Description: ${project.description}'),
                Text('Category: ${project.categoryLabel}'),
                Text('Link: ${project.link.isEmpty ? '-' : project.link}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _formKey.currentState!.reset();
                _titleController.clear();
                _descriptionController.clear();
                _linkController.clear();
                setState(() {
                  _category = 'web';
                });
              },
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint ?? label,
      errorMaxLines: 2,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: _inputDecoration('Title'),
                  validator: _validateTitle,
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: _inputDecoration('Description'),
                  validator: _validateDescription,
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: _inputDecoration('Category'),
                  initialValue: _category,
                  items: Project.categories.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === Project Link ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _linkController,
                  keyboardType: TextInputType.url,
                  decoration: _inputDecoration(
                    'Project Link (Optional)',
                    hint: 'https://github.com/username/proyek',
                  ),
                  validator: _validateLink,
                ),
              ),

              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save',
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
