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

`Ctrl-Space` と `Ctrl-@` は、端末や Windows の入力処理によって micro に届かない場合があります。`Ctrl-x m` を押し、画面下部に `Mark set` と出ることを確認してください。その後 `Ctrl-f` で移動し、`Ctrl-w` で切り取れます。既に `Ctrl-x m` にユーザー設定がある場合は、その設定が優先されます。

## テスト

micro を利用できる PowerShell で `./tests/run.ps1` を実行します。一時設定と保存しないバッファで mark・選択・切り取り・解除を検証します。`./tests/run.ps1 -Keys` では、追加で `Ctrl-x m` を押してキー経由の動作を検証できます。

## 現在の制限

- mark はバッファ単位ではなく、micro のプロセス全体で共有されます。
- kill/copy/yank には micro のクリップボードを使用します。
- Emacs の kill ring と、連続した kill の結合には対応していません。
- 行末で `Ctrl-k` を押しても改行は切り取りません。

## ライセンス

ライセンスはまだ指定されていません。
