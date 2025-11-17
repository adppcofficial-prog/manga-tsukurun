// 漫画ページのデータモデル
class MangaPage {
  final String id;
  final String imageUrl;
  final String? text;
  final int pageNumber;
  
  MangaPage({
    required this.id,
    required this.imageUrl,
    this.text,
    required this.pageNumber,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'text': text,
      'pageNumber': pageNumber,
    };
  }
  
  factory MangaPage.fromJson(Map<String, dynamic> json) {
    return MangaPage(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      text: json['text'] as String?,
      pageNumber: json['pageNumber'] as int,
    );
  }
}
