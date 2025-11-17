# マンガツクルン (Manga Tsukurun)

AIで簡単に漫画を作成できるFlutterアプリケーション

![Flutter](https://img.shields.io/badge/Flutter-3.35.4-blue)
![Dart](https://img.shields.io/badge/Dart-3.9.2-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## 🎨 概要

**マンガツクルン**は、参考デザインと台本をアップロードするだけで、AIが自動的に漫画を生成するアプリケーションです。

### 主な機能

- 📸 **複数の参考デザイン画像アップロード**
- 📝 **台本ファイルのアップロード**（テキスト・PDF対応）
- 🎯 **5種類の台本テンプレート**
- 🤖 **台本の自動解析とシーン分割**
- 📱 **2つの出力形式**（縦長LP型・画像型）
- 🌐 **Web・モバイル対応**

## 📱 スクリーンショット

### ホーム画面
アプリのメイン画面。新しい漫画の作成、テンプレート参照、プロジェクト一覧へのアクセスが可能です。

### アップロード画面
複数の参考画像と台本ファイルをアップロードできます。

### テンプレート画面
5種類のジャンル別台本テンプレートを提供。初心者でも簡単に始められます。

### プレビュー画面
生成された漫画をプレビュー。縦長LP型または画像型で表示を切り替え可能。

## 🚀 クイックスタート

### 必要な環境

- Flutter 3.35.4
- Dart 3.9.2
- Android Studio / VS Code
- Web browser（Web版の場合）

### インストール

```bash
# リポジトリをクローン
git clone https://github.com/YOUR_USERNAME/manga-tsukurun.git
cd manga-tsukurun

# 依存関係をインストール
flutter pub get

# Web版で実行
flutter run -d chrome

# モバイル版で実行（デバイスまたはエミュレータが必要）
flutter run
```

## 📖 使い方

### 1. 新しい漫画を作成

1. ホーム画面で「**新しい漫画を作成**」をタップ
2. プロジェクト名を入力
3. 参考デザイン画像をアップロード（複数可）
4. 台本ファイルをアップロード
5. 「**漫画を生成する**」をタップ

### 2. テンプレートを使用

1. 「**台本テンプレート**」をタップ
2. 好みのジャンルを選択：
   - 🌟 基本（日常系）
   - ⚔️ 冒険（ファンタジー）
   - 💕 恋愛（青春）
   - 😂 コメディ（ギャグ）
   - 🔍 ミステリー（推理）
3. プレビューで内容を確認
4. ダウンロードして編集
5. カスタマイズした台本をアップロード

### 3. 出力形式を選択

- **縦長LP型**: スクロール可能な連続形式
- **画像型**: ページめくり形式

## 📦 主要パッケージ

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: 6.1.5+1          # 状態管理
  file_picker: ^8.1.4        # ファイル選択
  image_picker: ^1.1.2       # 画像選択
  shared_preferences: 2.5.3  # ローカルストレージ
  http: 1.5.0                # HTTP通信
  dotted_border: ^2.1.0      # UI装飾
  flutter_spinkit: ^5.2.1    # ローディング
  path_provider: ^2.1.5      # ファイルパス
  image: ^4.3.0              # 画像処理
```

## 🏗️ プロジェクト構造

```
lib/
├── main.dart                 # アプリエントリーポイント
├── models/                   # データモデル
│   ├── manga_page.dart
│   └── manga_project.dart
├── screens/                  # 画面
│   ├── home_screen.dart
│   ├── upload_screen.dart
│   ├── generation_screen.dart
│   ├── preview_screen.dart
│   ├── projects_screen.dart
│   └── templates_screen.dart
├── services/                 # ビジネスロジック
│   └── manga_state.dart
└── widgets/                  # 再利用可能なウィジェット

templates/                    # 台本テンプレート
├── manga_script_template_basic.txt
├── manga_script_template_adventure.txt
├── manga_script_template_romance.txt
├── manga_script_template_comedy.txt
├── manga_script_template_mystery.txt
└── README_TEMPLATES.md
```

## 🎨 デザイン

### カラースキーム

- **Primary**: 深い紫 (#6B46C1)
- **Secondary**: 明るいオレンジ (#FF6B35)
- **デザインシステム**: Material Design 3

### フォント

- システムデフォルト（日本語対応）

## 🌟 機能詳細

### 複数画像アップロード

- 一度に複数の参考画像を選択可能
- 横スクロールギャラリーで一覧表示
- 個別削除機能付き
- リアルタイム枚数カウンター

### 台本解析

- 空行でシーンを自動分割
- 最大10シーンまで対応
- セリフ、ナレーション、効果音の認識

### テンプレート機能

- 5種類のジャンル別テンプレート
- プレビュー機能
- ワンタップダウンロード（Web版はクリップボードコピー）
- 詳細な使い方ガイド付き

## 🔧 開発

### ビルド

```bash
# Web版ビルド
flutter build web --release

# Android APKビルド
flutter build apk --release

# iOS ビルド
flutter build ios --release
```

### テスト

```bash
# すべてのテストを実行
flutter test

# 特定のテストを実行
flutter test test/widget_test.dart
```

### コード解析

```bash
# 静的解析
flutter analyze

# コードフォーマット
dart format .
```

## 🚧 現在の制限（デモ版）

- **AI画像生成**: プレースホルダー表示のみ
- **実際の漫画化**: 台本テキストの表示のみ

将来的にAI画像生成APIを統合予定です。

## 🗺️ ロードマップ

- [ ] AI画像生成API統合（DALL-E, Stable Diffusion）
- [ ] スタイル学習機能
- [ ] コマ割り自動化
- [ ] テキスト編集機能
- [ ] エクスポート形式追加（PDF, EPUB）
- [ ] クラウド保存
- [ ] SNS共有機能

## 🤝 貢献

プルリクエストを歓迎します！大きな変更の場合は、まずissueを開いて変更内容を議論してください。

## 📄 ライセンス

このプロジェクトは[MIT License](LICENSE)の下でライセンスされています。

## 👨‍💻 作者

- 開発者: Genspark AI Assistant
- プロジェクト: マンガツクルン

## 🙏 謝辞

- Flutter framework
- Material Design
- すべての貢献者の皆様

## 📞 サポート

問題や質問がある場合は、[Issues](https://github.com/YOUR_USERNAME/manga-tsukurun/issues)を開いてください。

---

**Made with ❤️ using Flutter**
