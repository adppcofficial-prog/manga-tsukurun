import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/manga_state.dart';
import '../models/manga_page.dart';
import 'preview_screen.dart';

class GenerationScreen extends StatefulWidget {
  const GenerationScreen({super.key});

  @override
  State<GenerationScreen> createState() => _GenerationScreenState();
}

class _GenerationScreenState extends State<GenerationScreen> {
  bool _isGenerating = false;
  double _progress = 0.0;
  String _currentStep = '台本を解析中...';
  
  @override
  void initState() {
    super.initState();
    _startGeneration();
  }
  
  Future<void> _startGeneration() async {
    setState(() {
      _isGenerating = true;
      _progress = 0.0;
    });
    
    final mangaState = Provider.of<MangaState>(context, listen: false);
    final scriptContent = mangaState.scriptContent;
    
    if (scriptContent == null) {
      _showError('台本が見つかりません');
      return;
    }
    
    try {
      // ステップ1: 台本解析
      setState(() {
        _currentStep = '台本を解析中...';
        _progress = 0.2;
      });
      await Future.delayed(const Duration(seconds: 1));
      
      // 台本を段落に分割（簡易的な実装）
      final scenes = _parseScript(scriptContent);
      
      // ステップ2: 各シーンの画像生成
      setState(() {
        _currentStep = '漫画ページを生成中...';
        _progress = 0.4;
      });
      
      // デモ用のサンプルページを生成（実際のAI生成は別途実装）
      for (int i = 0; i < scenes.length; i++) {
        final page = MangaPage(
          id: '${DateTime.now().millisecondsSinceEpoch}_$i',
          imageUrl: '', // 実際はAI生成画像のURL
          text: scenes[i],
          pageNumber: i + 1,
        );
        
        mangaState.addPage(page);
        
        setState(() {
          _progress = 0.4 + (0.5 * (i + 1) / scenes.length);
        });
        
        await Future.delayed(const Duration(milliseconds: 500));
      }
      
      // ステップ3: 完了
      setState(() {
        _currentStep = '完成しました！';
        _progress = 1.0;
        _isGenerating = false;
      });
      
      await Future.delayed(const Duration(seconds: 1));
      
      // プレビュー画面に遷移
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PreviewScreen(),
        ),
      );
      
    } catch (e) {
      _showError('生成中にエラーが発生しました: $e');
    }
  }
  
  List<String> _parseScript(String script) {
    // 台本を行ごとに分割して、空行でシーンを区切る
    final lines = script.split('\n');
    final scenes = <String>[];
    String currentScene = '';
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.isEmpty) {
        if (currentScene.isNotEmpty) {
          scenes.add(currentScene.trim());
          currentScene = '';
        }
      } else {
        currentScene += '$trimmedLine\n';
      }
    }
    
    if (currentScene.isNotEmpty) {
      scenes.add(currentScene.trim());
    }
    
    // 最低1シーン、最大10シーンに制限
    if (scenes.isEmpty) {
      scenes.add(script);
    }
    
    return scenes.length > 10 ? scenes.sublist(0, 10) : scenes;
  }
  
  void _showError(String message) {
    setState(() {
      _isGenerating = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('漫画生成中'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ローディングアニメーション
                SpinKitFadingCircle(
                  color: Theme.of(context).colorScheme.primary,
                  size: 80,
                ),
                
                const SizedBox(height: 48),
                
                // 進捗状況
                Text(
                  _currentStep,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // プログレスバー
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // パーセント表示
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                
                const SizedBox(height: 48),
                
                // 説明文
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AIが台本を分析して、\n漫画ページを自動生成しています',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
