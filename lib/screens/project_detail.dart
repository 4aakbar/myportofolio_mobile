import 'package:flutter/material.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Halaman detail satu [Project] yang dipilih dari daftar proyek.
class ProjectDetailPage extends StatelessWidget {
  const ProjectDetailPage({required this.project, super.key});

  final Project project;

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    return '$day/$month/${local.year}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final createdAt = project.createdAt;

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.category, size: 18),
                  label: Text(project.categoryLabel),
                ),
                Chip(
                  avatar: const Icon(Icons.star, size: 18),
                  label: Text('${project.starCount} star'),
                ),
              ],
            ),
            if (createdAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Dibuat: ${_formatDate(createdAt)}',
                style: textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Text('Deskripsi', style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(project.description),
            // Tautan hanya ditampilkan bila tidak kosong.
            if (project.link.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Tautan Proyek', style: textTheme.titleMedium),
              const SizedBox(height: 4),
              SelectableText(
                project.link,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
