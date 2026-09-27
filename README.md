# flutterkaigi2026_layer_lint

FlutterKaigi 2026 LT「アーキテクチャの依存ルールを Lint で強制する 〜自作 Analyzer Plugin でレイヤー違反を検知する〜」のデモリポジトリです。
Dart 3.10 で追加された公式の Analyzer Plugin システム（`package:analysis_server_plugin`）を使って、`lib/view/` のファイルが `lib/model/` を直接 import していたら `avoid_view_to_model_import` を報告するプラグインを自作しています。報告はエディタにも `flutter analyze` にも CI にも出ます。

```
flutterkaigi2026_layer_lint/
├─ packages/layer_lint/   # Analyzer Plugin 本体
│   ├─ lib/main.dart      # エントリポイント（top-level の plugin 変数）
│   ├─ lib/src/avoid_view_to_model_import.dart  # ルール + Visitor
│   ├─ lib/src/layer.dart # 層の定義テーブルとパス判定
│   └─ test/
├─ example/               # ルールを適用される側の Flutter アプリ
│   ├─ analysis_options.yaml
│   └─ lib/{view,view_model,model}/
└─ .github/workflows/analyze.yml
```

## セットアップ

動作確認環境: Flutter 3.41.6 / Dart 3.11.4（Analyzer Plugin には Dart 3.10 以上が必要です）

```sh
git clone <this repository>
cd flutterkaigi2026_layer_lint

# 1. プラグインの依存を取得してテストを実行
cd packages/layer_lint
dart pub get
dart test

# 2. example アプリで解析を実行（違反が 1 件報告されれば OK）
cd ../../example
flutter pub get
flutter analyze
```

期待される出力:

```
   info • View から Model への直接依存は禁止されています。 • lib/view/todo_page.dart:3:8 • avoid_view_to_model_import

1 issue found.
```

`dart analyze` を使うと correctionMessage（「ViewModel を経由してください。」）も表示されます。

## デモの手順

### 1. エディタで違反が見える

1. VS Code で `example/` フォルダを開く（初回はプラグインのビルドに数十秒かかります）
2. `lib/view/todo_page.dart` を開く
3. 3 行目の `'../model/todo.dart'`（`// DEMO: ここが検知される` の行）に波線が出て、Problems パネルに `avoid_view_to_model_import` が表示される

### 2. 直すと消える

`todo_page.dart` を、ViewModel 経由の正しい版（`todo_page_fixed.dart`）と同じ内容に書き換えます。違いは 3 箇所だけです。

```diff
-import '../model/todo.dart'; // DEMO: ここが検知される
+import '../view_model/todo_view_model.dart';
 ...
-  final List<Todo> todos = const [Todo(title: 'FlutterKaigi 2026 で登壇する')];
+  final TodoViewModel viewModel = TodoViewModel();
 ...
-        children: [for (final todo in todos) ListTile(title: Text(todo.title))],
+        children: [
+          for (final title in viewModel.titles) ListTile(title: Text(title)),
+        ],
```

手で打つ時間がないときは、ターミナルで `cp lib/view/todo_page_fixed.dart lib/view/todo_page.dart` を実行しても構いません。保存すると波線と Problems の表示が消えます。
デモが終わったら `git checkout lib/view/todo_page.dart` で違反版に戻します。

### 3. CI が落ちる

1. 違反版の `todo_page.dart` のまま GitHub に push する
2. Actions タブで `analyze` ワークフローを開く
3. `layer_lint (test)` job は緑、`example (flutter analyze)` job が `flutter analyze --fatal-infos` のステップで赤くなり、ログに上と同じ違反が出る

lint の報告は severity が info です。`flutter analyze` は既定で info でも失敗しますが、意図を明示するためにワークフローでは `--fatal-infos` を付けています（`dart analyze` は info だけでは失敗しないので、使う場合は `--fatal-infos` が必須です）。

## ルールの仕組み

- 層の判定は `lib/src/layer.dart` の定数テーブル（`layerDirectories` と `forbiddenDependencies`）で行います。
- import しているライブラリと import されているライブラリの**解決済みの URI**（`package:example/view/...`）を比べます。そのため、相対 import（`../model/todo.dart`）と package import（`package:example/model/todo.dart`）のどちらでも検知できます。
- lint rule（`registerLintRule`）として登録しているので、既定では無効です。`example/analysis_options.yaml` の `diagnostics:` で明示的に有効化しています。

## ハマりどころ

- **プラグインを変更したら Analysis Server の再起動が必要**です。VS Code ではコマンドパレットから `Dart: Restart Analysis Server` を実行します。`analysis_options.yaml` の `plugins:` を書き換えたときも同じです。
- **`print` は効きません**。プラグインは Analysis Server とは別の isolate で動くので、標準出力はどこにも表示されません。デバッグしたいときはログファイルに書き出してください。
- **プラグインがクラッシュしても、エディタには何も表示されません**。診断が出ないときは Analyzer Diagnostics ページ（VS Code では `Dart: Open Analyzer Diagnostics`）を開き、Plugins のページでエラーを確認してください。
- 公式ドキュメントの pubspec の例（`analyzer: ^8.0.0`）のままだと、テスト用パッケージ `analyzer_testing` が古い版（0.1.x）に解決されます。古い版には `testing_rules.md` にある `rule = MyRule();` の書き方がありません。このリポジトリでは最新版（`analysis_server_plugin: ^0.3.23` / `analyzer: ^14.4.0` / `analyzer_testing: ^0.4.2`）を使っています。
