VERSION = "0.1.0"

local buffer = import("micro/buffer")
local config = import("micro/config")
local micro = import("micro")
local util = import("micro/util")

local mark = nil

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

function set_mark(bp)
    local cursor = current_cursor(bp)
    mark = copy_loc(cursor.Loc)
    cursor:ResetSelection()
    micro.InfoBar():Message("Mark set")
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
    cursor:Relocate()
    bp:Relocate()
    return true
end

function kill_region(bp)
    if mark == nil then
        micro.InfoBar():Error("No mark set")
        return false
    end

    local cursor = current_cursor(bp)
    set_selection(cursor, mark, copy_loc(cursor.Loc))
    bp:Cut()
    mark = nil
    return true
end

function kill_line(bp)
    local cursor = current_cursor(bp)
    local line = bp.Buf:Line(cursor.Y)
    local end_of_line = util.CharacterCountInString(line)
    local point = copy_loc(cursor.Loc)

    if cursor.X < end_of_line then
        cursor:SetSelectionStart(point)
        cursor:SetSelectionEnd(buffer.Loc(end_of_line, cursor.Y))
        bp:Cut()
        return true
    end

    return false
end

function init()
    config.MakeCommand("emacs-mark", set_mark, config.NoComplete)
    config.MakeCommand("emacs-select-to-mark", select_to_mark, config.NoComplete)
    config.MakeCommand("emacs-exchange-point-and-mark", exchange_point_and_mark, config.NoComplete)
    config.MakeCommand("emacs-kill-region", kill_region, config.NoComplete)
    config.MakeCommand("emacs-kill-line", kill_line, config.NoComplete)

    config.TryBindKey("CtrlSpace", "lua:emacsbindings.set_mark", true)
    config.TryBindKey("<Ctrl-x><Ctrl-x>", "lua:emacsbindings.exchange_point_and_mark", true)
    config.TryBindKey("Ctrl-w", "lua:emacsbindings.kill_region", true)
    config.TryBindKey("Ctrl-k", "lua:emacsbindings.kill_line", true)
end
