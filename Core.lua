local addonName, ns = ...

-- Name of the Edit Mode layout this addon writes. It's rebuilt from Config.lua on every login,
-- so changes made to it by hand in Edit Mode don't last.
local LAYOUT_NAME = "MyUI"

-- Protected frames can't be moved during combat.
-- If we try while in combat, remember it and retry when combat ends.
local pending = false

-- A hidden frame in a stack takes up no space:
-- anchoring to it anchors to wherever it would sit instead.
local function ResolveAnchor(name, relativePoint)
    local frame = _G[name]
    local cfg = ns.config.frames[name]
    while frame and not frame:IsShown() and cfg and cfg.point do
        name, relativePoint = cfg.point[2], cfg.point[3]
        frame = _G[name]
        cfg = ns.config.frames[name]
    end
    return name, relativePoint
end

-- Frames managed by Edit Mode carry their system (and index, if there are several) on the frame
local function FindSystemInfo(layout, frame)
    for _, systemInfo in ipairs(layout.systems) do
        if systemInfo.system == frame.system
            and (frame.systemIndex == nil or systemInfo.systemIndex == frame.systemIndex) then
            return systemInfo
        end
    end
end

-- Returns false if the system has no such setting
local function SetSetting(systemInfo, setting, value)
    for _, entry in ipairs(systemInfo.settings) do
        if entry.setting == setting then
            entry.value = value
            return true
        end
    end
    return false
end

-- Unit frames store their size in the layout as steps of 5% above 100% (100% to 200%).
-- Returns false if the frame has no size setting in the layout.
local function SetFrameSize(systemInfo, name, scale)
    if systemInfo.system ~= Enum.EditModeSystem.UnitFrame then
        return false
    end
    local percent = math.min(math.max(scale * 100, 100), 200)
    local value = math.floor((percent - 100) / 5 + 0.5)
    if not SetSetting(systemInfo, Enum.EditModeUnitFrameSetting.FrameSize, value) then
        return false
    end
    if percent ~= scale * 100 then
        print(addonName .. ": " .. name .. " scale must be between 1.0 and 2.0")
    end
    return true
end

-- Positions and sizes of Edit Mode frames go into our Edit Mode layout. Blizzard's code then places
-- those frames itself: on login, after its own re-layouts and in combat.
-- Returns the names of frames whose scale went into the layout.
local function ApplyEditModeLayout(frames)
    local scaledInLayout = {}
    local layoutInfo = C_EditMode.GetLayouts()
    local presets = EditModePresetLayoutManager:GetCopyOfPresetLayouts()
    local numPresets = #presets

    local layout, index
    for i, saved in ipairs(layoutInfo.layouts) do
        if saved.layoutName == LAYOUT_NAME then
            layout, index = saved, i
        end
    end
    if not layout then
        -- Start from Blizzard's default layout; account-wide, so every character uses it
        layout = CopyTable(presets[1])
        layout.layoutName = LAYOUT_NAME
        layout.layoutType = Enum.EditModeLayoutType.Account
        table.insert(layoutInfo.layouts, layout)
        index = #layoutInfo.layouts
    end

    for name, cfg in pairs(frames) do
        local frame = _G[name]
        if frame.system then
            local systemInfo = FindSystemInfo(layout, frame)
            if not systemInfo then
                print(addonName .. ": not in the Edit Mode layout: " .. name)
            else
                if cfg.point then
                    local point, relativeTo, relativePoint, x, y = unpack(cfg.point)
                    relativeTo, relativePoint = ResolveAnchor(relativeTo, relativePoint)
                    systemInfo.isInDefaultPosition = false
                    systemInfo.anchorInfo = {
                        point = point,
                        relativeTo = relativeTo,
                        relativePoint = relativePoint,
                        offsetX = x,
                        offsetY = y,
                    }
                end
                if cfg.scale and SetFrameSize(systemInfo, name, cfg.scale) then
                    scaledInLayout[name] = true
                end
            end
        end
    end

    -- No bar art and no gryphons on action bar 1
    SetSetting(FindSystemInfo(layout, MainActionBar), Enum.EditModeActionBarSetting.HideBarArt, 1)
    SetSetting(FindSystemInfo(layout, MainActionBar.EndCaps.LeftEndCap), Enum.EditModeMainActionBarEndCapSetting.Hidden, 1)
    SetSetting(FindSystemInfo(layout, MainActionBar.EndCaps.RightEndCap), Enum.EditModeMainActionBarEndCapSetting.Hidden, 1)

    -- Save the way Blizzard does: preset layouts first, then the saved ones,
    -- with the active layout counted across both
    tAppendAll(presets, layoutInfo.layouts)
    layoutInfo.layouts = presets
    layoutInfo.activeLayout = numPresets + index
    C_EditMode.SaveLayouts(layoutInfo)
    C_EditMode.SetActiveLayout(layoutInfo.activeLayout)

    return scaledInLayout
end

-- Whatever the Edit Mode layout doesn't cover is applied to the frame directly
local function ApplyFrame(frame, cfg, scaledInLayout)
    if cfg.point and not frame.system then
        local point, relativeTo, relativePoint, x, y = unpack(cfg.point)
        frame:SetPoint(point, _G[relativeTo] or UIParent, relativePoint, x, y)
    end
    if cfg.scale and not scaledInLayout then
        frame:SetScale(cfg.scale)
    end
    if cfg.alpha then
        frame:SetAlpha(cfg.alpha)
    end
end

-- Things parented to this frame are never visible, even if Blizzard calls Show() on them
local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

-- The bag slots only show below the open bag window, not next to the action bars.
-- Covers both the separate and the combined bags setting.
local function AttachBagsBar(containerFrame)
    BagsBar:SetParent(containerFrame)
    BagsBar:ClearAllPoints()
    BagsBar:SetPoint("TOPRIGHT", containerFrame, "BOTTOMRIGHT", 0, -4)
end

local function MoveBagsBar()
    BagsBar:SetParent(hiddenParent)
    for _, containerFrame in ipairs({ ContainerFrame1, ContainerFrameCombinedBags }) do
        containerFrame:HookScript("OnShow", AttachBagsBar)
    end
end

-- The "Action Bar 2-5" checkboxes from the options menu, saved per character
local function EnableActionBars()
    local toggles = { GetActionBarToggles() }
    if toggles[1] and toggles[2] and toggles[3] and toggles[4] then
        return
    end
    toggles[1], toggles[2], toggles[3], toggles[4] = true, true, true, true
    -- The last argument is the "always show action bars" option; keep it as it is
    table.insert(toggles, GetCVarBool("alwaysShowActionBars"))
    SetActionBarToggles(unpack(toggles))
    MultiActionBar_Update()
end

local function ApplyAll()
    if InCombatLockdown() then
        pending = true
        return
    end
    pending = false
    EnableActionBars()

    local frames = {}
    for name, cfg in pairs(ns.config.frames) do
        if _G[name] then
            frames[name] = cfg
        else
            print(addonName .. ": frame not found: " .. name)
        end
    end

    local scaledInLayout = ApplyEditModeLayout(frames)

    -- Detach directly positioned frames first, so anchoring them to each other can't form a loop
    for name, cfg in pairs(frames) do
        if cfg.point and not _G[name].system then
            _G[name]:ClearAllPoints()
        end
    end
    for name, cfg in pairs(frames) do
        ApplyFrame(_G[name], cfg, scaledInLayout[name])
    end
end

-- When a frame that others are anchored to appears or disappears (e.g. the second status bar
-- when a reputation gets tracked), the frames above it have to move
local hooked = {}
for _, cfg in pairs(ns.config.frames) do
    local targetName = cfg.point and cfg.point[2]
    if targetName and ns.config.frames[targetName] and _G[targetName] and not hooked[targetName] then
        _G[targetName]:HookScript("OnShow", ApplyAll)
        _G[targetName]:HookScript("OnHide", ApplyAll)
        hooked[targetName] = true
    end
end

MoveBagsBar()

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:SetScript("OnEvent", function(_, event, isInitialLogin, isReloadingUi)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Only on login and /reload, not on every loading screen
        if isInitialLogin or isReloadingUi then
            ApplyAll()
        end
    elseif pending then
        ApplyAll()
    end
end)

-- /myui re-applies the config without a full reload
SLASH_MYUI1 = "/myui"
SlashCmdList.MYUI = ApplyAll
