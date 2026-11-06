local _, ns = ...

-- Only what differs from the game's defaults. Without a command, SetBinding unbinds the key.
function ns.ApplyKeybindings()
    -- Action bar 1
    SetBinding("Q", "ACTIONBUTTON1")
    SetBinding("E", "ACTIONBUTTON2")
    SetBinding("1", "ACTIONBUTTON3")
    SetBinding("2", "ACTIONBUTTON4")
    SetBinding("3", "ACTIONBUTTON5")
    SetBinding("4", "ACTIONBUTTON6")
    SetBinding("5", "ACTIONBUTTON7")
    SetBinding("6", "ACTIONBUTTON8")
    SetBinding("7", "ACTIONBUTTON9")
    SetBinding("8", "ACTIONBUTTON10")
    SetBinding("9", "ACTIONBUTTON11")
    SetBinding("0", "ACTIONBUTTON12")

    -- Action bar 2
    SetBinding("SHIFT-Q", "MULTIACTIONBAR1BUTTON1")
    SetBinding("SHIFT-E", "MULTIACTIONBAR1BUTTON2")
    SetBinding("SHIFT-1", "MULTIACTIONBAR1BUTTON3")
    SetBinding("SHIFT-2", "MULTIACTIONBAR1BUTTON4")
    SetBinding("SHIFT-3", "MULTIACTIONBAR1BUTTON5")
    SetBinding("SHIFT-4", "MULTIACTIONBAR1BUTTON6")

    -- Raid markers: skull, cross, moon
    SetBinding("F1", "RAIDTARGET8")
    SetBinding("F2", "RAIDTARGET7")
    SetBinding("F3", "RAIDTARGET5")

    SetBinding("F12", "SCREENSHOT")

    -- Defaults that are switched off
    SetBinding("-")
    SetBinding("=")
    SetBinding("SHIFT-UP")
    SetBinding("SHIFT-DOWN")
    SetBinding("SHIFT-MOUSEWHEELUP")
    SetBinding("SHIFT-MOUSEWHEELDOWN")
    SetBinding("F5")

    SaveBindings(1) -- 1 is the account-wide set, 2 the per-character one
end
