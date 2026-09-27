local micro = import("micro")
local buffer = import("micro/buffer")
local fmt = import("fmt")
local os = import("os")

if os.Getenv("MICRO_MARK_TEST") ~= "1" then
    return
end

function postinit()
    local success, failure = pcall(function()
        local pane = micro.CurPane()
        local cursor = pane.Buf:GetActiveCursor()
        pane.Buf:Insert(buffer.Loc(0, 0), "abcdef")
        cursor:GotoLoc(buffer.Loc(0, 0))
        keyboard_quit(pane)
        assert(set_mark(pane), "set_mark failed")
        assert(forward_char(pane), "forward_char failed")
        assert(cursor:HasSelection(), "mark did not extend selection")
        assert(kill_region(pane), "mark was not active after movement")
        assert(pane.Buf:Line(0) == "bcdef", "wrong region removed")
        assert(set_mark(pane), "reactivation failed")
        assert(set_mark(pane), "toggle failed")
        assert(not kill_region(pane), "toggle did not deactivate mark")
    end)
    if success then
        fmt.Println("MARK TEST PASS")
        if os.Getenv("MICRO_TEST_KEY") == "1" then
            local original_set_mark = set_mark
            set_mark = function(pane)
                original_set_mark(pane)
                forward_char(pane)
                if kill_region(pane) and pane.Buf:Line(0) == "cdef" then
                    fmt.Println("MARK KEY TEST PASS")
                    os.Exit(0)
                end
                fmt.Println("MARK KEY TEST FAIL")
                os.Exit(1)
            end
            return
        end
        os.Exit(0)
    else
        fmt.Println("MARK TEST FAIL: " .. tostring(failure))
        os.Exit(1)
    end
end