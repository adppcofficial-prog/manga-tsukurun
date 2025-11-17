import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../services/manga_state.dart';
import 'generation_screen.dart';
import 'templates_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final List<String> _referenceImagePaths = [];
  final List<Uint8List> _referenceImageBytes = [];
  String? _scriptPath;
  String? _scriptContent;
  final TextEditingController _titleController = TextEditingController();
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickReferenceImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true, // 複数選択を許可
        withData: true, // Web対応: bytesを取得
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          setState(() {
            if (kIsWeb) {
              // Web版: bytesを使用
              if (file.bytes != null) {
                _referenceImageBytes.add(file.bytes!);
                _referenceImagePaths.add(file.name);
              }
            } else {
              // モバイル版: pathを使用
              if (file.path != null) {
                _referenceImagePaths.add(file.path!);
              }
            }
          });
          
          if (!mounted) return;
          final mangaState = Provider.of<MangaState>(context, listen: false);
          mangaState.addReferenceImage(kIsWeb ? file.name : file.path!);
        }
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length}枚の参考デザインをアップロードしました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _removeReferenceImage(int index) {
    setState(() {
      _referenceImagePaths.removeAt(index);
      if (kIsWeb && index < _referenceImageBytes.length) {
        _referenceImageBytes.removeAt(index);
      }
    });
    
    final mangaState = Provider.of<MangaState>(context, listen: false);
    mangaState.removeReferenceImage(index);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('画像を削除しました'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _pickScript() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf'],
        allowMultiple: false,
        withData: true, // Web対応: bytesを取得
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String content;
        
        if (kIsWeb) {
          // Web版: bytesからUTF-8でテキストを読み取り
          if (file.bytes != null) {
            content = utf8.decode(file.bytes!);
          } else {
            throw Exception('ファイルの読み込みに失敗しました');
          }
        } else {
          // モバイル版: pathからファイルを読み取り
          final ioFile = File(file.path!);
          content = await ioFile.readAsString();
        }
        
        setState(() {
          _scriptPath = file.name;
          _scriptContent = content;
        });
        
        if (!mounted) return;
        final mangaState = Provider.of<MangaState>(context, listen: false);
        mangaState.setScript(file.name, content);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('台本をアップロードしました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToGeneration() {
    if (_referenceImagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('参考デザインを最低1枚アップロードしてください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (_scriptContent == null || _scriptContent!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('台本をアップロードしてください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('プロジェクト名を入力してください'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final mangaState = Provider.of<MangaState>(context, listen: false);
    mangaState.createProject(title);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GenerationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新しい漫画を作成'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // プロジェクト名入力
              Text(
                'プロジェクト名',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '例: 冒険の物語',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 参考デザインアップロード（複数対応）
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '参考デザイン',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (_referenceImagePaths.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_referenceImagePaths.length}枚',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // 画像追加ボタン
              GestureDetector(
                onTap: _pickReferenceImages,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                  dashPattern: const [8, 4],
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '画像を追加（複数選択可）',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'タップして画像を選択',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 選択された画像一覧
              if (_referenceImagePaths.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _referenceImagePaths.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: kIsWeb && index < _referenceImageBytes.length
                                    ? Image.memory(
                                        _referenceImageBytes[index],
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(_referenceImagePaths[index]),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () => _removeReferenceImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // 台本アップロード
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '台本',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TemplatesScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lightbulb_outline, size: 18),
                    label: const Text('テンプレートを見る'),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickScript,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  color: Theme.of(context).colorScheme.secondary,
                  strokeWidth: 2,
                  dashPattern: const [8, 4],
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _scriptContent != null
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.description,
                                      color: Theme.of(context).colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _scriptPath?.split('/').last ?? '台本',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: Text(
                                    _scriptContent!,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.description,
                                size: 64,
                                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '台本をアップロード',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'テキスト / PDFファイル',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // 生成ボタン
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _navigateToGeneration,
                  icon: const Icon(Icons.auto_awesome, size: 24),
                  label: const Text(
                    '漫画を生成する',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
