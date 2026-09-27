VERSION = "0.2.0"

local buffer = import("micro/buffer")
local config = import("micro/config")
local micro = import("micro")
local util = import("micro/util")

local mark = nil
local mark_active = false

local function current_cursor(bp)
    return bp.Buf:GetActiveCursor()
end

local function copy_loc(loc)
    return buffer.Loc(loc.X, loc.Y)
end

local function loc_before(a, b)
    return a.Y < b.Y or (a.Y == b.Y and a.X <= b.X)
end

local function set_selection(cursor, a, b)
    if loc_before(a, b) then
        cursor:SetSelectionStart(a)
        cursor:SetSelectionEnd(b)
    else
        cursor:SetSelectionStart(b)
        cursor:SetSelectionEnd(a)
    end
end

local function deactivate_mark(cursor)
    mark_active = false
    if cursor ~= nil then
        cursor:ResetSelection()
    end
end

local function move(bp, move_fn)
    local cursor = current_cursor(bp)
    move_fn(cursor)
    if mark_active and mark ~= nil then
        set_selection(cursor, mark, copy_loc(cursor.Loc))
    end
    cursor:StoreVisualX()
    bp:Relocate()
    return true
end

function set_mark(bp)
    local cursor = current_cursor(bp)
    if mark_active and mark ~= nil and mark.X == cursor.X and mark.Y == cursor.Y then
        deactivate_mark(cursor)
        micro.InfoBar():Message("Mark deactivated")
        return true
    end
    mark = copy_loc(cursor.Loc)
    mark_active = true
    cursor:ResetSelection()
    micro.InfoBar():Message("Mark set")
    return true
end

function keyboard_quit(bp)
    deactivate_mark(current_cursor(bp))
    micro.InfoBar():Message("Quit")
    return true
end

function select_to_mark(bp)
    if mark == nil then
        micro.InfoBar():Error("No mark set")
        return false
    end

    local cursor = current_cursor(bp)
    set_selection(cursor, mark, copy_loc(cursor.Loc))
    return true
end

function exchange_point_and_mark(bp)
    if mark == nil then
        micro.InfoBar():Error("No mark set")
        return false
    end

    local cursor = current_cursor(bp)
    local point = copy_loc(cursor.Loc)
    cursor:GotoLoc(mark)
    mark = point
    if mark_active then
        set_selection(cursor, mark, copy_loc(cursor.Loc))
    end
    cursor:Relocate()
    bp:Relocate()
    return true
end

function kill_region(bp)
    if mark == nil or not mark_active then
        micro.InfoBar():Error("The mark is not active")
        return false
    end

    local cursor = current_cursor(bp)
    set_selection(cursor, mark, copy_loc(cursor.Loc))
    bp:Cut()
    deactivate_mark(cursor)
    return true
end

function copy_region(bp)
    if mark == nil or not mark_active then
        micro.InfoBar():Error("The mark is not active")
        return false
    end

    local cursor = current_cursor(bp)
    set_selection(cursor, mark, copy_loc(cursor.Loc))
    bp:Copy()
    deactivate_mark(cursor)
    return true
end

function yank(bp)
    local cursor = current_cursor(bp)
    mark = copy_loc(cursor.Loc)
    mark_active = false
    bp:Paste()
    return true
end

function kill_line(bp)
    local cursor = current_cursor(bp)
    local line = bp.Buf:Line(cursor.Y)
    local end_of_line = util.CharacterCountInString(line)

    if cursor.X < end_of_line then
        bp:SelectToEndOfLine()
        bp:Cut()
        return true
    end

    return false
end

function forward_char(bp)
    return move(bp, function(c) c:Right() end)
end

function backward_char(bp)
    return move(bp, function(c) c:Left() end)
end

function next_line(bp)
    return move(bp, function(c) c:Down() end)
end

function previous_line(bp)
    return move(bp, function(c) c:Up() end)
end

function forward_word(bp)
    return move(bp, function(c) c:WordRight() end)
end

function backward_word(bp)
    return move(bp, function(c) c:WordLeft() end)
end

function move_beginning_of_line(bp)
    return move(bp, function(c) c:Start() end)
end

function move_end_of_line(bp)
    return move(bp, function(c) c:End() end)
end

function init()
    config.MakeCommand("emacs-mark", set_mark, config.NoComplete)
    config.MakeCommand("emacs-select-to-mark", select_to_mark, config.NoComplete)
    config.MakeCommand("emacs-exchange-point-and-mark", exchange_point_and_mark, config.NoComplete)
    config.MakeCommand("emacs-kill-region", kill_region, config.NoComplete)
    config.MakeCommand("emacs-copy-region", copy_region, config.NoComplete)
    config.MakeCommand("emacs-yank", yank, config.NoComplete)
    config.MakeCommand("emacs-kill-line", kill_line, config.NoComplete)
    config.MakeCommand("emacs-keyboard-quit", keyboard_quit, config.NoComplete)

    config.TryBindKey("CtrlSpace", "lua:emacsbindings.set_mark", true)
    config.TryBindKey("Ctrl-w", "lua:emacsbindings.kill_region", true)
    config.TryBindKey("Alt-w", "lua:emacsbindings.copy_region", true)
    config.TryBindKey("Ctrl-y", "lua:emacsbindings.yank", true)
    config.TryBindKey("Ctrl-k", "lua:emacsbindings.kill_line", true)
    config.TryBindKey("Ctrl-g", "lua:emacsbindings.keyboard_quit", true)
    config.TryBindKey("<Ctrl-x><Ctrl-x>", "lua:emacsbindings.exchange_point_and_mark", true)
    config.TryBindKey("Ctrl-f", "lua:emacsbindings.forward_char", true)
    config.TryBindKey("Ctrl-b", "lua:emacsbindings.backward_char", true)
    config.TryBindKey("Ctrl-n", "lua:emacsbindings.next_line", true)
    config.TryBindKey("Ctrl-p", "lua:emacsbindings.previous_line", true)
    config.TryBindKey("Alt-f", "lua:emacsbindings.forward_word", true)
    config.TryBindKey("Alt-b", "lua:emacsbindings.backward_word", true)
    config.TryBindKey("Ctrl-a", "lua:emacsbindings.move_beginning_of_line", true)
    config.TryBindKey("Ctrl-e", "lua:emacsbindings.move_end_of_line", true)
end
