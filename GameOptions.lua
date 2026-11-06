local _, ns = ...

-- The "Action Bar 2-5" checkboxes, saved per character
local function EnableActionBars()
    local toggles = { GetActionBarToggles() }
    if toggles[1] and toggles[2] and toggles[3] and toggles[4] then
        return
    end
    toggles[1], toggles[2], toggles[3], toggles[4] = true, true, true, true
    -- The last argument is the "always show action bars" option; keep it as it is
    table.insert(toggles, GetCVarBool("alwaysShowActionBars"))
    SetActionBarToggles(unpack(toggles))
end

-- Values from the game's options dialog
function ns.ApplyGameOptions()
    EnableActionBars()
    SetCVar("deselectOnClick", 1)       -- sticky targeting off (the setting is inverted)
    SetCVar("autoLootDefault", 1)       -- enable auto loot
    SetCVar("cameraSmoothStyle", 0)     -- camera following: never adjust camera
    SetCVar("countdownForCooldowns", 1) -- numbers on cooldowns
end
