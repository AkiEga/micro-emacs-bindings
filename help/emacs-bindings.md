# emacs-bindings

This plugin provides a small Emacs-style editing layer for micro.

## Key bindings

| Key | Action |
| --- | --- |
| `Ctrl-Space` | Set/activate the mark (press again to deactivate) |
| `Ctrl-@` | Set/activate the mark (may share the same input limitations as `Ctrl-Space`) |
| `Ctrl-x m` | Set/activate the mark without NUL input; release Ctrl before pressing m |
| `Ctrl-g` | Deactivate the mark (keyboard-quit) |
| `Ctrl-x Ctrl-x` | Exchange point and mark |
| `Ctrl-w` | Cut the region between point and mark |
| `Alt-w` | Copy the region between point and mark |
| `Ctrl-y` | Yank (paste), leaving the mark at the yank start |
| `Ctrl-k` | Cut from the cursor to the end of the current line |

While the mark is active, movement commands (`Ctrl-f/b/n/p`, `Alt-f/b`,
`Ctrl-a/e`) extend the selection from the mark, approximating Emacs
transient-mark-mode.

If neither `Ctrl-Space` nor `Ctrl-@` displays `Mark set`, try `Ctrl-x m`.
Terminal or Windows input handling may prevent those keys from reaching micro.
An existing user binding for `Ctrl-x m` takes precedence over this fallback.

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
