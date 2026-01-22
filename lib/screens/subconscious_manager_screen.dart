import 'package:flutter/material.dart';

class SubconsciousManagerScreen extends StatefulWidget {
  const SubconsciousManagerScreen({super.key});

  @override
  State<SubconsciousManagerScreen> createState() =>
      _SubconsciousManagerScreenState();
}

class _SubconsciousManagerScreenState extends State<SubconsciousManagerScreen> {
  final TextEditingController _intentionController = TextEditingController();
  final TextEditingController _reflectionController = TextEditingController();

  final List<String> _ritualLabels = const [
    '深呼吸を3分',
    'ジャーナリング',
    'イメージング',
    'アファメーション',
    '軽いストレッチ',
  ];
  late final List<bool> _ritualChecks =
      List<bool>.filled(_ritualLabels.length, false);

  double _awarenessLevel = 3;
  int _moodIndex = 2;

  final List<String> _moodLabels = const [
    '落ち着き',
    '集中',
    '充足感',
    'ひらめき',
    '高揚',
  ];

  @override
  void dispose() {
    _intentionController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _saveLog() {
    final completedRituals = _ritualChecks.where((checked) => checked).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '意図を保存しました（習慣: $completedRituals/${_ritualLabels.length}）',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('潜在意識管理ツール'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '潜在意識を解放するための意図と習慣を整えます。',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: '今日の意図',
            subtitle: '「どう在りたいか」を短く書き出します。',
            child: TextField(
              controller: _intentionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '例：自分の直感に従い、柔軟に表現する',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: '潜在意識を整える習慣',
            subtitle: '今日取り入れたいリチュアルにチェック。',
            child: Column(
              children: _ritualLabels.asMap().entries.map((entry) {
                return CheckboxListTile(
                  value: _ritualChecks[entry.key],
                  onChanged: (value) {
                    setState(() {
                      _ritualChecks[entry.key] = value ?? false;
                    });
                  },
                  title: Text(entry.value),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: 'トリガー管理',
            subtitle: '潜在意識を閉じがちな状況を把握します。',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _TriggerChip(label: '焦り'),
                _TriggerChip(label: '疲労'),
                _TriggerChip(label: '情報過多'),
                _TriggerChip(label: '比較'),
                _TriggerChip(label: '睡眠不足'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SectionCard(
            title: '内省ログ',
            subtitle: '気づきレベルとメモを記録します。',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '気づきレベル: ${_awarenessLevel.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Slider(
                  value: _awarenessLevel,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: _awarenessLevel.toStringAsFixed(0),
                  onChanged: (value) {
                    setState(() {
                      _awarenessLevel = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  '現在の気分: ${_moodLabels[_moodIndex]}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ToggleButtons(
                  isSelected: List.generate(
                    _moodLabels.length,
                    (index) => index == _moodIndex,
                  ),
                  onPressed: (index) {
                    setState(() {
                      _moodIndex = index;
                    });
                  },
                  children: _moodLabels
                      .map(
                        (label) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(label),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _reflectionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: '気づきや直感を書き留める',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveLog,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('今日の記録を保存'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _TriggerChip extends StatelessWidget {
  final String label;

  const _TriggerChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
