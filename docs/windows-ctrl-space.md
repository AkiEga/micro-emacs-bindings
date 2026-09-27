# Windows で Ctrl-Space が mark を設定しない原因

調査日: 2026-09-28

## 結論

調査した Windows 版 micro では、入力ライブラリ tcell が NUL 形式の
`Ctrl-Space` を破棄していた。プラグインの `set_mark` が呼ばれないため、
後から `Ctrl-w` を押すと `The mark is not active` と表示される。

VS Code のキー処理を迂回し、Windows コンソール入力 API へ直接イベントを
渡して再現した。したがって「VS Code がキーを捕捉することが原因」という
当初の説明には根拠がなく、少なくともそれとは独立した micro 側の問題がある。

## 確認環境

| 項目 | 値 |
| --- | --- |
| OS | Windows |
| micro | 2.0.15 |
| micro コミット | `6a62575bcfdf4965f187eedafceb3400316e612b` |
| ビルド情報 | `vcs.modified=true` |
| 入力ライブラリ | `github.com/micro-editor/tcell/v2 v2.0.13` |

依存バージョンは、実際に使用する micro 実行ファイルに埋め込まれた
Go ビルド情報から確認した。別バージョンや別 OS での再現は未確認。

## 入力が失われる処理

[tcell v2.0.13 の Windows 入力実装](https://github.com/micro-editor/tcell/blob/v2.0.13/console_win.go)
にある `getConsoleInput()` は、次の順序で入力を処理する。

1. `krec.ch != 0` なら、文字イベントを作成する。
2. `krec.ch == 0` なら、仮想キーコードを `vkKeys` で検索する。
3. 表に該当キーがなければ、イベントを発行せず `return nil` する。

`Ctrl-Space` 相当の入力は `VK_SPACE = 0x20`、文字コード `0`、Ctrl 修飾となる。
このバージョンでは `vkSpace` の定数はあるが、`vkKeys` に登録されていない。
そのため、micro のキーバインド処理や Lua プラグインへ届く前に破棄される。

## 再現方法と結果

普段の設定や編集中のファイルを使わず、一時設定ディレクトリと未保存バッファで
検証した。診断用プラグインで `set_mark` の呼び出し回数を数え、別プロセスから
`WriteConsoleInputW` を使って `CONIN$` へキー押下イベントを投入した。
各イベントは `KEY_EVENT`、`bKeyDown = true`、`wRepeatCount = 1` とした。

| 比較入力 | 仮想キー / 文字コード / 修飾 | mark 呼び出し | 後続の Ctrl-f による選択 |
| --- | --- | --- | --- |
| Ctrl-Space (NUL) | `0x20 / 0 / LEFT_CTRL_PRESSED` | 0回 | なし |
| 空白文字 + Ctrl | `0x20 / 32 / LEFT_CTRL_PRESSED` | 0回 | なし。空白が挿入された |
| Ctrl-x、続いて m | `0x58 / 24 / LEFT_CTRL_PRESSED`、`0x4D / 109 / 0` | 1回 | あり |

各ケースで後続の `Ctrl-f` と診断終了用の `F12` は処理された。
NUL 形式で mark を設定できない結果は、上記の入力実装と一致する。
空白文字として送るだけでも、既存の `CtrlSpace` バインドには一致しない。

この検証は Windows 入力 API 以降を対象とする。物理キーボードからの入力が
OS・IME・VS Code に捕捉されるかどうかは測定していない。

## 回避策と修正対象

- `Ctrl-x` を押し、Ctrl を離して `m` を押す。`Mark set` の表示後に移動・切り取りを行う。
- この代替キーに既存のユーザーバインドがある場合は、ユーザー設定を優先する。
- `Ctrl-@` も環境によって同じ NUL 入力になるため、確実な回避策ではない。
- プラグインの再配置や `mark_active` の変更では、破棄済みの入力は復元できない。

根本修正の対象は tcell の Windows 入力処理であり、Ctrl 修飾付き `VK_SPACE` を
適切な `KeyCtrlSpace` イベントへ変換する必要がある。修正した依存を組み込んだ
micro での再検証が必要。このリポジトリでは micro 本体や tcell は変更していない。

## プラグイン側の回帰テスト

リポジトリ直下の PowerShell で実行する。

```powershell
./tests/run.ps1
./tests/run.ps1 -Keys
```

最初のコマンドは mark 設定・移動・切り取り・解除を検証する。
`-Keys` では追加で `Ctrl-x m` を手入力し、キー経由の動作を検証する。
これらは上記の `WriteConsoleInputW` 診断とは別のテストであり、
成功しても `Ctrl-Space` 自体が修正されたことにはならない。