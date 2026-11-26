local _, ns = ...

-- Action bars at the bottom of the screen, with the keys on each button.
-- Core block (bars 1 and 2) left of the middle, bar 3 right of it:
--
--   Ctrl+Q  Ctrl+E  Ctrl+1  Ctrl+2  Ctrl+3  Ctrl+4      bar 2, buttons 1-6
--   Shift+Q Shift+E Shift+1 Shift+2 Shift+3 Shift+4     bar 1, buttons 7-12    Shift+5 Shift+6 Shift+7 Shift+8 Shift+9 Shift+0     bar 3, buttons 7-12
--   Q       E       1       2       3       4           bar 1, buttons 1-6     5       6       7       8       9       0           bar 3, buttons 1-6

-- Only what differs from the game's defaults. Without a command, SetBinding unbinds the key.
function ns.ApplyKeybindings()
    -- Action bar 1, first row: plain core keys
    SetBinding("Q", "ACTIONBUTTON1")
    SetBinding("E", "ACTIONBUTTON2")
    SetBinding("1", "ACTIONBUTTON3")
    SetBinding("2", "ACTIONBUTTON4")
    SetBinding("3", "ACTIONBUTTON5")
    SetBinding("4", "ACTIONBUTTON6")

    -- Action bar 1, second row: core keys with Shift
    SetBinding("SHIFT-Q", "ACTIONBUTTON7")
    SetBinding("SHIFT-E", "ACTIONBUTTON8")
    SetBinding("SHIFT-1", "ACTIONBUTTON9")
    SetBinding("SHIFT-2", "ACTIONBUTTON10")
    SetBinding("SHIFT-3", "ACTIONBUTTON11")
    SetBinding("SHIFT-4", "ACTIONBUTTON12")

    -- Action bar 2: core keys with Ctrl
    SetBinding("CTRL-Q", "MULTIACTIONBAR1BUTTON1")
    SetBinding("CTRL-E", "MULTIACTIONBAR1BUTTON2")
    SetBinding("CTRL-1", "MULTIACTIONBAR1BUTTON3")
    SetBinding("CTRL-2", "MULTIACTIONBAR1BUTTON4")
    SetBinding("CTRL-3", "MULTIACTIONBAR1BUTTON5")
    SetBinding("CTRL-4", "MULTIACTIONBAR1BUTTON6")

    -- Action bar 3, first row: 5 to 0
    SetBinding("5", "MULTIACTIONBAR2BUTTON1")
    SetBinding("6", "MULTIACTIONBAR2BUTTON2")
    SetBinding("7", "MULTIACTIONBAR2BUTTON3")
    SetBinding("8", "MULTIACTIONBAR2BUTTON4")
    SetBinding("9", "MULTIACTIONBAR2BUTTON5")
    SetBinding("0", "MULTIACTIONBAR2BUTTON6")

    -- Action bar 3, second row: 5 to 0 with Shift
    SetBinding("SHIFT-5", "MULTIACTIONBAR2BUTTON7")
    SetBinding("SHIFT-6", "MULTIACTIONBAR2BUTTON8")
    SetBinding("SHIFT-7", "MULTIACTIONBAR2BUTTON9")
    SetBinding("SHIFT-8", "MULTIACTIONBAR2BUTTON10")
    SetBinding("SHIFT-9", "MULTIACTIONBAR2BUTTON11")
    SetBinding("SHIFT-0", "MULTIACTIONBAR2BUTTON12")

    -- Raid markers: skull, cross, moon
    SetBinding("F1", "RAIDTARGET8")
    SetBinding("F2", "RAIDTARGET7")
    SetBinding("F3", "RAIDTARGET5")

    SetBinding("F12", "SCREENSHOT")

    -- Defaults that are switched off
    SetBinding("-")
    SetBinding("=")
    -- Action bar 1 paging (Shift+1 to Shift+6 page by default, they're bound to buttons above)
    SetBinding("SHIFT-UP")
    SetBinding("SHIFT-DOWN")
    SetBinding("SHIFT-MOUSEWHEELUP")
    SetBinding("SHIFT-MOUSEWHEELDOWN")
    SetBinding("F5")

    SaveBindings(1) -- 1 is the account-wide set, 2 the per-character one
end
