import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('台本テンプレート'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Card(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.description,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '台本テンプレート',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '様々なジャンルの台本テンプレートをダウンロードできます',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // テンプレート一覧
              _TemplateCard(
                icon: Icons.sunny,
                title: '基本テンプレート',
                subtitle: '日常系・学園もの',
                difficulty: '初級者向け',
                difficultyColor: Colors.green,
                description: 'シンプルで分かりやすい構造の基本テンプレート。初めての方におすすめです。',
                fileName: 'manga_script_template_basic.txt',
                content: _basicTemplate,
              ),
              
              const SizedBox(height: 16),
              
              _TemplateCard(
                icon: Icons.casino,
                title: '冒険テンプレート',
                subtitle: 'ファンタジー・バトル',
                difficulty: '中級者向け',
                difficultyColor: Colors.orange,
                description: '勇者の旅立ちから仲間との出会いまで。アクションシーンを含む冒険ストーリー。',
                fileName: 'manga_script_template_adventure.txt',
                content: _adventureTemplate,
              ),
              
              const SizedBox(height: 16),
              
              _TemplateCard(
                icon: Icons.favorite,
                title: '恋愛テンプレート',
                subtitle: '青春・ロマンス',
                difficulty: '中級者向け',
                difficultyColor: Colors.orange,
                description: '転校生との出会いから始まる青春恋愛物語。感情表現豊かなストーリー。',
                fileName: 'manga_script_template_romance.txt',
                content: _romanceTemplate,
              ),
              
              const SizedBox(height: 16),
              
              _TemplateCard(
                icon: Icons.emoji_emotions,
                title: 'コメディテンプレート',
                subtitle: 'ギャグ・お笑い',
                difficulty: '中級者向け',
                difficultyColor: Colors.orange,
                description: '寝坊からの爆笑展開！デフォルメ表現とテンポの良いギャグストーリー。',
                fileName: 'manga_script_template_comedy.txt',
                content: _comedyTemplate,
              ),
              
              const SizedBox(height: 16),
              
              _TemplateCard(
                icon: Icons.search,
                title: 'ミステリーテンプレート',
                subtitle: '推理・サスペンス',
                difficulty: '上級者向け',
                difficultyColor: Colors.red,
                description: '密室から消えた宝石の謎。伏線と推理が織りなす本格ミステリー。',
                fileName: 'manga_script_template_mystery.txt',
                content: _mysteryTemplate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String difficulty;
  final Color difficultyColor;
  final String description;
  final String fileName;
  final String content;

  const _TemplateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.difficulty,
    required this.difficultyColor,
    required this.description,
    required this.fileName,
    required this.content,
  });

  Future<void> _downloadTemplate(BuildContext context) async {
    try {
      // Webプラットフォームの場合はクリップボードにコピー
      if (Platform.isAndroid || Platform.isIOS) {
        // モバイルの場合はファイルとして保存
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(content);
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$fileNameをダウンロードしました'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else {
        // Webの場合はクリップボードにコピー
        await Clipboard.setData(ClipboardData(text: content));
        
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('テンプレートをクリップボードにコピーしました'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showPreview(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
          child: Column(
            children: [
              AppBar(
                title: Text(title),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('閉じる'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _downloadTemplate(context);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('ダウンロード'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    difficulty,
                    style: TextStyle(
                      color: difficultyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPreview(context),
                    icon: const Icon(Icons.visibility),
                    label: const Text('プレビュー'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _downloadTemplate(context),
                    icon: const Icon(Icons.download),
                    label: const Text('ダウンロード'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// テンプレートの内容定義
const String _basicTemplate = '''==========================================
マンガツクルン - 台本テンプレート（基本）
==========================================

【使い方】
- 各シーンは空行で区切ってください
- 1シーン = 1ページの漫画になります
- セリフ、ト書き、シーン説明を自由に記述できます
- 最大10シーンまで対応しています

==========================================

シーン1:
オープニング。朝の街並み。太陽が昇る様子。
主人公が目覚めるシーン。

キャラクターA: 「おはよう！今日も良い天気だね」

==========================================

シーン2:
学校の廊下。友達と会話するシーン。
背景には他の生徒たちが歩いている。

キャラクターB: 「おはよう！昨日の宿題やった？」

キャラクターA: 「あ、忘れてた！どうしよう...」

==========================================

シーン3:
教室。授業が始まる直前。
先生が黒板に数式を書いている。

ナレーション: こうして、いつもの日常が始まった。

==========================================

シーン4:
放課後。校門前。夕日が差し込む。
友達と一緒に帰宅する様子。

キャラクターB: 「今日は一緒に図書館で勉強しない？」

キャラクターA: 「いいね！行こう！」

==========================================
''';

const String _adventureTemplate = '''==========================================
マンガツクルン - 台本テンプレート（冒険編）
==========================================

タイトル: 勇者の冒険
ジャンル: ファンタジー冒険

==========================================

シーン1: 旅立ちの朝
小さな村の広場。朝日が昇り始めている。
村人たちが主人公を見送りに集まっている。
主人公は冒険者の装備を身につけている。

勇者: 「みんな、行ってくるよ！必ず魔王を倒して帰ってくる！」

村長: 「勇者よ、村の希望を背負っているのだ。気をつけて行ってくれ」

==========================================

シーン2: 森の中で
深い森の中。大きな木々が生い茂っている。
主人公が道を進んでいると、モンスターが現れる。

ナレーション: 旅立って数時間。勇者は最初の試練に遭遇した。

スライム: 「ギュルルル...」

勇者: 「来たか！でも、こんなモンスターには負けない！」

==========================================

シーン3: 初めての戦闘
森の中。勇者がスライムと戦っている。
剣を構えて、魔法を放つシーン。

勇者: 「ファイアボール！」

効果音: ドカーン！

スライム: 「ギュエー！」（消滅する）

==========================================
''';

const String _romanceTemplate = '''==========================================
マンガツクルン - 台本テンプレート（恋愛編）
==========================================

タイトル: 桜の下で
ジャンル: 青春恋愛

==========================================

シーン1: 春の始まり
学校の正門。満開の桜が咲き誇っている。
新学期の初日。たくさんの生徒が登校している。

ナレーション: 春。新しい出会いの季節が始まった。

主人公・ユウタ: 「高校2年生か...今年はどんな年になるかな」

==========================================

シーン2: 運命の出会い
廊下の曲がり角。ユウタが急いで走っている。
角を曲がったところで、女子生徒とぶつかってしまう。

効果音: ドン！

女子生徒・サクラ: 「きゃっ！」（本を落としてしまう）

ユウタ: 「ご、ごめん！大丈夫？」

==========================================

シーン3: 初めての会話
廊下。散らばった本を二人で拾っている。
ユウタがサクラを見上げると、桜の花びらが舞っている。

サクラ: 「平気です。こちらこそ急いでて...」（顔を赤らめる）

ユウタ: 「あの、君は転校生？見たことない顔だけど」

==========================================
''';

const String _comedyTemplate = '''==========================================
マンガツクルン - 台本テンプレート（ギャグ・コメディ編）
==========================================

タイトル: 爆笑！学園ライフ
ジャンル: ギャグコメディ

==========================================

シーン1: 遅刻だー！
主人公の部屋。目覚まし時計が鳴り響いている。
主人公が飛び起きる。時計を見ると8時30分！

主人公・タケシ: 「うわあああ！寝坊したー！！」

効果音: ガバッ！

==========================================

シーン2: 超高速準備
部屋の中。タケシが超スピードで着替えている。
服が飛び散り、カバンの中身がバラバラになっている。

効果音: バタバタバタ！

タケシ: 「制服、制服...あ、裏返しだった！」

タケシの母: （階下から）「タケシ、朝ごはんは？」

タケシ: 「食べてる時間ない！行ってきまーす！」

==========================================

シーン3: まさかの展開
学校の正門前。タケシが全力で走ってくる。
しかし門の前で先生が立っている！

タケシ: 「やった！間に合った！」

先生: 「ところで今日は土曜日だから休みだよ」

タケシ: 「えええええええ！！！」

効果音: ガーン！

==========================================
''';

const String _mysteryTemplate = '''==========================================
マンガツクルン - 台本テンプレート（ミステリー編）
==========================================

タイトル: 消えた宝石の謎
ジャンル: 推理ミステリー

==========================================

シーン1: 事件発生
豪華な洋館の居間。夜の雨が窓を叩いている。
警察官と探偵が現場を調べている。

刑事・山田: 「これは厄介な事件だ...」

探偵・黒木: 「盗まれたのは100万ドルのダイヤモンド。しかし不思議なことに、窓も扉も施錠されたままだった」

ナレーション: 密室から消えた宝石。謎が謎を呼ぶ事件が始まった。

==========================================

シーン2: 容疑者たち
洋館のホール。4人の容疑者が並んでいる。
緊張した雰囲気が漂っている。

黒木: 「この中に犯人がいる。それは間違いない」

メイド・花子: 「私は何も知りません...」（震えている）

==========================================

シーン3: 真犯人
黒木が一人の人物を指差す。
その人物の顔がアップになる。

黒木: 「犯人はあなただ！」

執事・山本: 「くっ...」（観念した表情）

==========================================
''';
