import 'package:flutter/foundation.dart';
import '../models/manga_project.dart';
import '../models/manga_page.dart';

// 漫画プロジェクトの状態管理
class MangaState extends ChangeNotifier {
  MangaProject? _currentProject;
  final List<MangaProject> _projects = [];
  bool _isLoading = false;
  String? _error;
  
  // 参考画像とスクリプト（複数画像対応）
  final List<String> _referenceImagePaths = [];
  String? _scriptPath;
  String? _scriptContent;
  
  // Getters
  MangaProject? get currentProject => _currentProject;
  List<MangaProject> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<String> get referenceImagePaths => _referenceImagePaths;
  String? get scriptPath => _scriptPath;
  String? get scriptContent => _scriptContent;
  
  // 参考画像を追加
  void addReferenceImage(String path) {
    _referenceImagePaths.add(path);
    notifyListeners();
  }
  
  // 参考画像を削除
  void removeReferenceImage(int index) {
    if (index >= 0 && index < _referenceImagePaths.length) {
      _referenceImagePaths.removeAt(index);
      notifyListeners();
    }
  }
  
  // 全ての参考画像をクリア
  void clearReferenceImages() {
    _referenceImagePaths.clear();
    notifyListeners();
  }
  
  // スクリプトを設定
  void setScript(String path, String content) {
    _scriptPath = path;
    _scriptContent = content;
    notifyListeners();
  }
  
  // 新しいプロジェクトを作成
  void createProject(String title) {
    final project = MangaProject(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      pages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      outputFormat: 'vertical',
    );
    _currentProject = project;
    _projects.add(project);
    notifyListeners();
  }
  
  // プロジェクトを更新
  void updateProject(MangaProject project) {
    _currentProject = project;
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
    }
    notifyListeners();
  }
  
  // ページを追加
  void addPage(MangaPage page) {
    if (_currentProject != null) {
      final updatedPages = [..._currentProject!.pages, page];
      final updatedProject = _currentProject!.copyWith(
        pages: updatedPages,
        updatedAt: DateTime.now(),
      );
      updateProject(updatedProject);
    }
  }
  
  // 出力形式を変更
  void setOutputFormat(String format) {
    if (_currentProject != null) {
      final updatedProject = _currentProject!.copyWith(
        outputFormat: format,
        updatedAt: DateTime.now(),
      );
      updateProject(updatedProject);
    }
  }
  
  // ローディング状態を設定
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // エラーを設定
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
  
  // プロジェクトをクリア
  void clearProject() {
    _currentProject = null;
    _referenceImagePaths.clear();
    _scriptPath = null;
    _scriptContent = null;
    notifyListeners();
  }
}
