# note_autopost 実装指示書（Django 版）

note 自動投稿ワークフローを Django で実装する際の決定事項と最小要件をまとめています。MVP のスコープで実装順序まで含めて記載しています。

## 0. 技術スタック（固定）
- Django 4.x / 5.x
- Django REST Framework（API 化する場合）
- DB: PostgreSQL（推奨）/ SQLite（MVP）
- 非同期: Celery + Redis（推奨、MVP 同期可）
- ブラウザ自動化: Playwright（Antigravity 上で動作想定）
- Secrets: .env（django-environ / python-dotenv）

## 1. プロジェクト構成（例）
```
note_autopost/
  manage.py
  config/
    settings.py
    urls.py
    wsgi.py
    asgi.py
  apps/
    accounts/
    notes/
    posting/
    analytics/
    core/
  templates/
  static/
```

## 2. 必須動線（MVP）
- 新規登録 → ログイン（Remember で 3 日維持）
- note アカウント追加（複数）
- 初回は手動で note にログインし、セッション状態を保存
- 投稿フォームでテーマ/文字数入力 → タイトル生成 → 記事生成 → note へ下書き保存（自動）
- 履歴保存（下書き URL、実行ログ）
- 分析は手入力 + AI 考察（MVP）

## 3. Django 設定（認証/セッション 3 日）
`config/settings.py`
```python
SESSION_COOKIE_AGE = 60 * 60 * 24 * 3   # 3日
SESSION_SAVE_EVERY_REQUEST = True       # アクティブなら延命
SESSION_EXPIRE_AT_BROWSER_CLOSE = False

CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = False
SECURE_SSL_REDIRECT = True  # 本番のみ
```

### ログイン「Remember me」
- チェックあり: `set_expiry(SESSION_COOKIE_AGE)`
- チェックなし: `set_expiry(0)`（ブラウザを閉じたら消去）

## 4. DB 設計（モデル概要）
### accounts アプリ
- User（Django 標準で可）
- 役割: `is_staff` を管理者扱い
- 凍結: `is_active=False`

### notes アプリ（note アカウント管理）
`NoteAccount`
- `user` (FK)
- `display_name` (str)
- `persona_json` (JSON)
- `content_policy_json` (JSON)
- `auth_state_encrypted` (text) — ブラウザ状態（cookie 等）を暗号化保存
- `auth_status` (choice: OK/EXPIRED/REAUTH/ERROR)
- `last_auth_check_at` (datetime)
- 暗号化は Fernet（cryptography）で実装（KMS は後続）

### posting アプリ（生成～下書き保存）
- `PostJob`: user, note_account, theme(text), target_chars(int 必須), status(choice: DRAFT/TITLE_READY/ARTICLE_READY/SAVING/SAVED/FAILED), error_code(str), created_at(datetime)
- `GeneratedTitle`: post_job(FK), title, score(optional), selected(bool)
- `GeneratedArticle`: post_job(FK), title_selected, body(text), outline_json
- `NoteDraft`: post_job(FK), note_draft_url(text), saved_at, mode("browser")
- `AutomationRun`: run_type(LOGIN_CHECK/SAVE_DRAFT/FETCH_METRICS), status(SUCCESS/FAIL), error_code, trace_path(optional: Playwright trace)

### analytics アプリ（分析）
- `ArticleMetric`: note_account(FK), url, title, pv, likes, revenue, purchases, total, collected_at
- `AIInsight`: metric(FK), insight_text, next_actions_json

## 5. 画面構成（テンプレート）
- `/signup`
- `/login`
- `/dashboard`
- `/note-accounts/`（一覧）
- `/note-accounts/new`（追加）
- `/note-accounts/<id>/auth`（ログイン確認・再認証）
- `/posts/new`（投稿フォーム）
- `/posts/<id>/titles`（タイトル選択）
- `/posts/<id>/article`（記事確認）
- `/posts/<id>/save-draft`（下書き保存実行）
- `/history`（下書き履歴）
- `/analytics`（分析一覧）
- 管理者: Django Admin（/admin）で User 凍結/復旧、AutomationRun 監視、NoteAccount の auth_status 確認

## 6. LLM 統合方針
- Provider 抽象化（MVP は OpenAI のみ）
- `LLMProviderSetting`（user ごと）: provider(openai/gemini/claude), api_key_encrypted, default_model
- 抽象メソッド:
  - `generate_titles(theme, chars, persona, policy)`
  - `generate_article(title, theme, chars, persona, policy)`

## 7. note 自動化（最重要）
### 前提
- 初回は Antigravity 上のブラウザで手動ログイン → cookie/localStorage 等を `auth_state` として保存
- 次回以降は `auth_state` を復元して自動ログイン → 下書き保存

### SAVE_DRAFT フロー（擬似）
入力: note_account_id, title(選択済), body(記事本文)
1. `auth_state` を復号してブラウザにロード
2. note トップへアクセス
3. ログイン確認（プロフィール要素等） → NG なら `NEED_REAUTH`
4. 「新規作成（投稿）」へ遷移
5. タイトル入力
6. 本文入力（貼付）
7. 「下書き保存」をクリック
8. 成功判定（下書き保存済み表示/URL 変化/下書き一覧出現）
9. 下書き URL を取得して DB 保存

エラーコード固定: `NEED_REAUTH`, `SELECTOR_CHANGED`, `TIMEOUT`, `RATE_LIMIT`, `UNKNOWN`

### 再認証（REAUTH）画面
`/note-accounts/<id>/auth`
- 「ログインを開始」ボタン → headed ブラウザ起動 or 手動ログイン手順表示
- 「ログイン完了した」ボタン → 現在状態を保存（`auth_state` 更新）→ `auth_status=OK`

## 8. 非同期実行（Celery 推奨）
- キュー投入対象: タイトル生成、記事生成、下書き保存（ブラウザ操作）
- キュー分離推奨: `llm_queue`, `browser_queue`（重い処理を分離）

## 9. API 最小設計（拡張前提）
- `POST /api/posts/`（job 作成）
- `POST /api/posts/{id}/generate_titles`
- `POST /api/posts/{id}/select_title`
- `POST /api/posts/{id}/generate_article`
- `POST /api/posts/{id}/save_note_draft`
- `GET /api/history`

## 10. 実装順序（推奨）
1. Django プロジェクト作成 + accounts（signup/login/remember）
2. note_accounts CRUD（複数登録、persona/policy JSON 保存 UI）
3. 投稿フロー: PostJob 作成 → タイトル生成 → 選択 → 記事生成
4. 下書き保存（ブラウザ自動化、auth_state 保存/復元、エラーコード整備）
5. 履歴（Draft URL / Run ログ）
6. 分析（手入力 + AI 考察）

## 11. タスク分割（Antigravity 投入用）
- Task A: Django 認証（signup/login/logout、remember me 3 日）
- Task B: NoteAccount 管理（複数追加・編集、persona_json/content_policy_json UI）
- Task C: 投稿フロー（PostJob 作成→タイトル生成→選択→記事生成）
- Task D: 自動下書き保存（Playwright、auth_state 保存/復元、save_draft 実装、エラーコード整理）
- Task E: 管理者＆監査（admin 登録、AutomationRun 表示）
