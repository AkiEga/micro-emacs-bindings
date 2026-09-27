# micro-emacs-bindings

[micro](https://micro-editor.github.io/) に Emacs 風の mark/region 操作を追加するプラグインです。

## 必要環境

- micro 2.0.15 以降

## インストール

micro で次のコマンドを実行します。

```text
> plugin install https://github.com/akiega/micro-emacs-bindings
```

ローカルで開発する場合は、このリポジトリを micro のプラグインディレクトリへ配置してください。通常は次の場所です。

```text
~/.config/micro/plug/emacs-bindings
```

## キーバインド

| キー | 動作 |
| --- | --- |
| `Ctrl-Space` | 現在位置に mark を設定します。同じ位置でもう一度押すと解除します |
| `Ctrl-@` | `Ctrl-Space` と同様に mark を設定します |
| `Ctrl-x m` | mark 設定の代替キー。`Ctrl-x` の後、Ctrl を離して `m` を押します |
| `Ctrl-g` | mark と選択範囲を解除します (`keyboard-quit`) |
| `Ctrl-x Ctrl-x` | point（カーソル位置）と mark を入れ替えます |
| `Ctrl-w` | point と mark の間を切り取ります (`kill-region`) |
| `Alt-w` | point と mark の間をコピーします (`copy-region`) |
| `Ctrl-y` | クリップボードの内容を貼り付け、貼り付け開始位置に mark を残します (`yank`) |
| `Ctrl-k` | カーソル位置から現在行の末尾までを切り取ります (`kill-line`) |

## 基本操作

1. `Ctrl-Space` で mark を設定します。
2. カーソルを移動して範囲を選択します。
3. `Ctrl-w` で切り取るか、`Alt-w` でコピーします。
4. `Ctrl-y` で貼り付けます。

mark の設定後、プラグインの移動コマンドを使用すると mark から現在位置までの選択範囲が更新されます。

### mark を設定できない場合

Windows 版 micro 2.0.15 が使用する tcell v2.0.13 では、NUL 形式の `Ctrl-Space` が入力処理で破棄されることを確認しています。`Ctrl-@` も同じ問題に遭遇する場合があります。

`Ctrl-x` を押してから Ctrl を離して `m` を押し、画面下部の `Mark set` を確認してください。その後 `Ctrl-f` で移動し、`Ctrl-w` で切り取れます。既存の `Ctrl-x m` のユーザー設定は上書きしません。

原因と検証結果は [Windows の Ctrl-Space 調査記録](docs/windows-ctrl-space.md) を参照してください。

## テスト

micro を利用できる PowerShell で、リポジトリ直下から実行します。

```powershell
./tests/run.ps1
```

一時設定と未保存バッファで mark・選択・切り取り・解除を検証します。`./tests/run.ps1 -Keys` では、追加で `Ctrl-x m` を押してキー経由の動作を検証できます。これらは `Ctrl-Space` の入力処理そのものを検証するテストではありません。

## 現在の制限

- mark はバッファ単位ではなく、micro のプロセス全体で共有されます。
- kill/copy/yank には micro のクリップボードを使用します。
- Emacs の kill ring と、連続した kill の結合には対応していません。
- 行末で `Ctrl-k` を押しても改行は切り取りません。

## ライセンス

ライセンスはまだ指定されていません。
