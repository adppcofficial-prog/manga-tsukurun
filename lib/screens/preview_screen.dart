import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/manga_state.dart';
import '../models/manga_page.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  String _outputFormat = 'vertical'; // 'vertical' or 'pages'

  @override
  Widget build(BuildContext context) {
    final mangaState = Provider.of<MangaState>(context);
    final project = mangaState.currentProject;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('プレビュー'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('プロジェクトが見つかりません'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadManga(context, project.pages),
            tooltip: 'ダウンロード',
          ),
        ],
      ),
      body: Column(
        children: [
          // 出力形式選択
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Text(
                  '出力形式:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'vertical',
                        label: Text('縦長LP型'),
                        icon: Icon(Icons.view_day),
                      ),
                      ButtonSegment(
                        value: 'pages',
                        label: Text('画像型'),
                        icon: Icon(Icons.collections),
                      ),
                    ],
                    selected: {_outputFormat},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        _outputFormat = newSelection.first;
                      });
                      mangaState.setOutputFormat(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          // プレビュー表示
          Expanded(
            child: _outputFormat == 'vertical'
                ? _buildVerticalPreview(project.pages)
                : _buildPagesPreview(project.pages),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _downloadManga(context, project.pages),
        icon: const Icon(Icons.download),
        label: const Text('ダウンロード'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildVerticalPreview(List<MangaPage> pages) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Column(
              children: pages.map((page) => _buildPageCard(page)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPagesPreview(List<MangaPage> pages) {
    return PageView.builder(
      itemCount: pages.length,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              margin: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildPageCard(pages[index]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${index + 1} / ${pages.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageCard(MangaPage page) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(minHeight: 200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ページ番号
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ページ ${page.pageNumber}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 画像プレースホルダー（実際のAI生成画像が入る場所）
            Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple[50]!,
                    Colors.orange[50]!,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'AI画像生成エリア',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '※ デモ版では画像は生成されません',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // テキスト内容
            if (page.text != null && page.text!.isNotEmpty) ...[
              Row(
                children: [
                  Icon(
                    Icons.description,
                    size: 20,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '台本',
                    style: TextStyle(
                      color: Colors.amber[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber[200]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  page.text!,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _downloadManga(BuildContext context, List<MangaPage> pages) {
    // ダウンロード機能の実装（実際のファイル保存処理）
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_outputFormat == 'vertical' ? '縦長LP型' : '画像型'}形式でダウンロードを開始します',
        ),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // TODO: 実際のダウンロード処理を実装
    // - 縦長LP型の場合: すべてのページを1つの長い画像として結合
    // - 画像型の場合: 各ページを個別の画像ファイルとして保存
  }
}
