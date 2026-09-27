# emacs-bindings

This plugin provides a small Emacs-style editing layer for micro.

## Key bindings

| Key | Action |
| --- | --- |
| `Ctrl-Space` | Set the mark at the current cursor position |
| `Ctrl-x Ctrl-x` | Exchange point and mark |
| `Ctrl-w` | Cut the region between point and mark |
| `Ctrl-k` | Cut from the cursor to the end of the current line |

The mark is currently process-global and the plugin uses micro's clipboard for
cut and paste operations. Kill-ring merging and kill-at-end-of-line behavior
are not implemented yet.

## Installation

From micro:

```text
plugin install https://github.com/akiega/micro-emacs-bindings
```

For local development, copy this directory to the active micro plugin
directory, usually `~/.config/micro/plug/emacs-bindings`.
