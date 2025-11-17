import 'manga_page.dart';

// 漫画プロジェクトのデータモデル
class MangaProject {
  final String id;
  final String title;
  final List<MangaPage> pages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String outputFormat; // 'vertical' or 'pages'
  
  MangaProject({
    required this.id,
    required this.title,
    required this.pages,
    required this.createdAt,
    required this.updatedAt,
    this.outputFormat = 'vertical',
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'pages': pages.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'outputFormat': outputFormat,
    };
  }
  
  factory MangaProject.fromJson(Map<String, dynamic> json) {
    return MangaProject(
      id: json['id'] as String,
      title: json['title'] as String,
      pages: (json['pages'] as List)
          .map((p) => MangaPage.fromJson(p as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      outputFormat: json['outputFormat'] as String? ?? 'vertical',
    );
  }
  
  MangaProject copyWith({
    String? id,
    String? title,
    List<MangaPage>? pages,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? outputFormat,
  }) {
    return MangaProject(
      id: id ?? this.id,
      title: title ?? this.title,
      pages: pages ?? this.pages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      outputFormat: outputFormat ?? this.outputFormat,
    );
  }
}
