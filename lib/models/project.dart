import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Proyek portofolio yang disinkronkan dengan API `/api/v1/projects/`.
///
/// Field mengikuti `ProjectSerializer` di backend Django: `title`,
/// `description`, `category`, dan `link` dapat ditulis klien, sedangkan
/// `id`, `category_display`, `created_at`, `star_count`, dan `is_starred`
/// diisi oleh server sehingga tidak ikut dikirim saat `POST`.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    this.category = 'other',
    this.link = '',
    this.id,
    this.categoryDisplay = '',
    this.createdAt,
    this.starCount = 0,
    this.isStarred = false,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// Pilihan kategori yang diterima backend (`Project.PROJECT_CATEGORY_CHOICES`).
  static const Map<String, String> categories = {
    'web': 'Web Application',
    'mobile': 'Mobile Application',
    'ai': 'AI/ML',
    'data': 'Data Analytics',
    'other': 'Other',
  };

  /// UUID proyek; dibuat oleh server.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;

  /// Kode kategori, misalnya `web` atau `mobile`.
  @JsonKey(defaultValue: 'other')
  final String category;

  /// Tautan proyek (opsional, boleh kosong).
  @JsonKey(defaultValue: '')
  final String link;

  /// Label kategori yang mudah dibaca, misalnya `Web Application`.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;

  @JsonKey(includeToJson: false)
  final DateTime? createdAt;

  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  @JsonKey(includeToJson: false, defaultValue: false)
  final bool isStarred;

  /// Label kategori: dari server bila ada, jika tidak dari [categories].
  String get categoryLabel => categoryDisplay.isNotEmpty
      ? categoryDisplay
      : (categories[category] ?? category);

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
