local _, ns = ...
local oUF = ns.oUF

-- Flat bars like Tukui: a plain white texture, colored by oUF
local TEXTURE = "Interface\\Buttons\\WHITE8x8"
local BAR_GAP = 3

-- Settings only the custom frames have. Position and scale come from the Blizzard frame's
-- entry in Config.lua, so the layout stays the same with or without the custom frames.
local SIZES = {
    player = { width = 220, healthHeight = 26, powerHeight = 8 },
    target = {
        width = 220, healthHeight = 26, powerHeight = 8,
        -- Buffs above the frame: 8 icons fill its width exactly (8 * 24 + 7 * 4 = 220).
        -- Debuffs right of the frame, debuffsPerRow icons per row.
        auraSize = 24, auraSpacing = 4, maxAuras = 16, debuffsPerRow = 4, auraTimerFontSize = 10,
    },
    -- Small frames: only a health bar with the name
    targettarget = { width = 110, healthHeight = 20 },
    focus = { width = 110, healthHeight = 20 },
    pet = { width = 110, healthHeight = 20 },
}

-- Gap between the target frame and its buffs and debuffs
local AURA_GAP = 6

-- The remaining time on aura icons is drawn by their cooldown spiral, in this font
local timerFont = CreateFont("MyUIAuraTimerFont")
timerFont:SetFont(STANDARD_TEXT_FONT, SIZES.target.auraTimerFontSize, "OUTLINE")

-- Dark background with a 1 pixel black border around a bar
local function AddBackdrop(bar)
    local backdrop = CreateFrame("Frame", nil, bar, "BackdropTemplate")
    backdrop:SetPoint("TOPLEFT", -1, 1)
    backdrop:SetPoint("BOTTOMRIGHT", 1, -1)
    backdrop:SetFrameLevel(bar:GetFrameLevel() - 1)
    backdrop:SetBackdrop({ bgFile = TEXTURE, edgeFile = TEXTURE, edgeSize = 1 })
    backdrop:SetBackdropColor(0.1, 0.1, 0.1)
    backdrop:SetBackdropBorderColor(0, 0, 0)
end

local function AddText(frame, bar, point, x, tag)
    local text = bar:CreateFontString(nil, "OVERLAY")
    text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
    text:SetPoint(point, bar, point, x, 0)
    frame:Tag(text, tag)
    return text
end

-- A semi-transparent bar inside the health bar, starting where `anchor` ends.
-- oUF fills it with incoming heals or shields.
local function AddPredictionBar(health, anchor, width, r, g, b, a)
    local bar = CreateFrame("StatusBar", nil, health)
    bar:SetPoint("TOP")
    bar:SetPoint("BOTTOM")
    bar:SetPoint("LEFT", anchor, "RIGHT")
    bar:SetWidth(width)
    bar:SetStatusBarTexture(TEXTURE)
    bar:SetStatusBarColor(r, g, b, a)
    return bar
end

-- Tukui look for aura icons: the icon cropped slightly (hides the game's built-in icon edge)
-- inside a 1 pixel black border
local function StyleAuraIcon(button, icon)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
    local border = button:CreateTexture(nil, "BACKGROUND", nil, -1)
    border:SetAllPoints()
    border:SetColorTexture(0, 0, 0)
end

-- An aura container with the shared icon settings
local function AddAuras(self, cfg, filter, options)
    local auras = self:CreateAuras(options)
    auras.size = cfg.auraSize
    auras.elementSpacing = cfg.auraSpacing
    auras.lineSpacing = cfg.auraSpacing
    auras.maxFrameCount = cfg.maxAuras
    auras.showCount = true
    auras.showDebuffBorder = true
    auras.PostCreateButton = function(_, button)
        button.Cooldown:SetCountdownFont("MyUIAuraTimerFont")
        StyleAuraIcon(button, button.Icon)
    end
    auras:AddGroup(filter)
    return auras
end

local function Style(self, unit)
    local cfg = SIZES[unit]
    if cfg.powerHeight then
        self:SetSize(cfg.width, cfg.healthHeight + BAR_GAP + cfg.powerHeight)
    else
        self:SetSize(cfg.width, cfg.healthHeight)
    end

    local health = CreateFrame("StatusBar", nil, self)
    health:SetPoint("TOPLEFT")
    health:SetPoint("TOPRIGHT")
    health:SetHeight(cfg.healthHeight)
    health:SetStatusBarTexture(TEXTURE)
    -- Gray if tagged by someone else or offline, class color for players, reaction color for NPCs
    health.colorTapping = true
    health.colorDisconnected = true
    health.colorClass = true
    health.colorReaction = true
    AddBackdrop(health)
    self.Health = health

    -- Incoming heals (own ones brighter) and shields, after the current health.
    -- They stop at the end of the bar; a shield on full health shows as a white line at the edge.
    local playerHeals = AddPredictionBar(health, health:GetStatusBarTexture(), cfg.width, 0, 1, 0.5, 0.5)
    local otherHeals = AddPredictionBar(health, playerHeals:GetStatusBarTexture(), cfg.width, 0, 0.6, 0.3, 0.5)
    local shield = AddPredictionBar(health, otherHeals:GetStatusBarTexture(), cfg.width, 1, 1, 1, 0.35)
    local overShield = health:CreateTexture(nil, "OVERLAY")
    overShield:SetPoint("TOPRIGHT")
    overShield:SetPoint("BOTTOMRIGHT")
    overShield:SetWidth(2)
    overShield:SetColorTexture(1, 1, 1, 0.9)
    health.HealingPlayer = playerHeals
    health.HealingOther = otherHeals
    health.DamageAbsorb = shield
    health.OverDamageAbsorbIndicator = overShield
    health.incomingHealOverflow = 1

    -- Texts go on a layer above the heal and shield bars
    local textLayer = CreateFrame("Frame", nil, health)
    textLayer:SetAllPoints()
    textLayer:SetFrameLevel(shield:GetFrameLevel() + 1)

    if cfg.powerHeight then
        local power = CreateFrame("StatusBar", nil, self)
        power:SetPoint("BOTTOMLEFT")
        power:SetPoint("BOTTOMRIGHT")
        power:SetHeight(cfg.powerHeight)
        power:SetStatusBarTexture(TEXTURE)
        power.colorPower = true
        power.frequentUpdates = true
        AddBackdrop(power)
        self.Power = power
    end

    if unit == "player" then
        AddText(self, textLayer, "LEFT", 4, "[curpp]")
        AddText(self, textLayer, "RIGHT", -4, "[curhp]")
    elseif unit == "target" then
        -- The name ends before the health number, cut off with "..." if too long
        local healthText = AddText(self, textLayer, "RIGHT", -4, "[curhp]")
        local name = AddText(self, textLayer, "LEFT", 4, "[smartlevel] [name]")
        name:SetPoint("RIGHT", healthText, "LEFT", -4, 0)
        name:SetJustifyH("LEFT")
        name:SetWordWrap(false)
    else
        -- Spans the bar with a fixed width, so long names get cut off with "..."
        local name = AddText(self, textLayer, "LEFT", 4, "[name]")
        name:SetPoint("RIGHT", textLayer, "RIGHT", -4, 0)
        name:SetJustifyH("CENTER")
        name:SetWordWrap(false)
    end

    if unit == "target" then
        -- Buffs in rows above the frame, growing upwards
        local buffs = AddAuras(self, cfg, "HELPFUL", { initialAnchor = "BOTTOMLEFT", growthY = "UP" })
        buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, AURA_GAP)
        buffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, AURA_GAP)

        -- Debuffs right of the frame, filling rightwards, then downwards
        local debuffWidth = cfg.debuffsPerRow * (cfg.auraSize + cfg.auraSpacing) - cfg.auraSpacing
        local debuffs = AddAuras(self, cfg, "HARMFUL",
            { initialAnchor = "TOPLEFT", growthY = "DOWN", layoutLimit = debuffWidth })
        debuffs:SetPoint("TOPLEFT", self, "TOPRIGHT", AURA_GAP, 0)
        debuffs:SetSize(debuffWidth, cfg.auraSize)
    end
end

oUF:RegisterStyle("MyUI", Style)
oUF:SetActiveStyle("MyUI")

-- Placed like the Blizzard frame it replaces, from that frame's entry in Config.lua.
-- Anchored to a Blizzard frame that has a custom replacement, it anchors to the replacement instead.
local function Spawn(unit, blizzardFrame)
    local frame = oUF:Spawn(unit, "MyUI" .. blizzardFrame)
    local layout = ns.config.frames[blizzardFrame]
    local point, relativeTo, relativePoint, x, y = unpack(layout.point)
    frame:SetPoint(point, _G["MyUI" .. relativeTo] or _G[relativeTo], relativePoint, x, y)
    if layout.scale then
        frame:SetScale(layout.scale)
    end
end

-- Frames others are anchored to come first
Spawn("player", "PlayerFrame")
Spawn("target", "TargetFrame")
Spawn("targettarget", "TargetFrameToT")
Spawn("focus", "FocusFrame")
Spawn("pet", "PetFrame")

-- Test mode (/myui test): dummy buffs and debuffs in the target frame's layout, to see a full boss fight.
-- The game fills the real aura container itself and can't be fed fake auras, so this draws
-- its own icons in the same places.
local TEST_ICONS = {
    "Interface\\Icons\\Spell_Shadow_ShadowWordPain",
    "Interface\\Icons\\Spell_Fire_Immolation",
    "Interface\\Icons\\Ability_Rogue_Rupture",
    "Interface\\Icons\\Spell_Nature_Slow",
    "Interface\\Icons\\Spell_Holy_WordFortitude",
    "Interface\\Icons\\Spell_Nature_Regeneration",
    "Interface\\Icons\\Spell_Holy_MagicalSentry",
    "Interface\\Icons\\Ability_Warrior_BattleShout",
}

-- Debuff border colors: magic, curse, disease, poison
local TEST_DEBUFF_COLORS = { { 0.2, 0.6, 1 }, { 0.6, 0, 1 }, { 0.6, 0.4, 0 }, { 0, 0.6, 0 } }

local testFrame

local function CreateTestFrame()
    local cfg = SIZES.target
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetScale(ns.config.frames.TargetFrame.scale)
    frame:SetSize(cfg.width, cfg.auraSize)
    frame:SetPoint("BOTTOMLEFT", MyUITargetFrame, "TOPLEFT", 0, AURA_GAP)
    frame.cooldowns = {}

    local step = cfg.auraSize + cfg.auraSpacing
    local buffsPerRow = math.floor((cfg.width + cfg.auraSpacing) / step)

    for i = 0, 2 * cfg.maxAuras - 1 do
        local isDebuff = i < cfg.maxAuras
        local index = i % cfg.maxAuras

        local icon = CreateFrame("Frame", nil, frame)
        icon:SetSize(cfg.auraSize, cfg.auraSize)
        if isDebuff then
            -- Right of the frame, filling rightwards, then downwards
            local column, row = index % cfg.debuffsPerRow, math.floor(index / cfg.debuffsPerRow)
            icon:SetPoint("TOPLEFT", MyUITargetFrame, "TOPRIGHT", AURA_GAP + column * step, -row * step)
        else
            -- Rows above the frame, growing upwards
            local column, row = index % buffsPerRow, math.floor(index / buffsPerRow)
            icon:SetPoint("BOTTOMLEFT", column * step, row * step)
        end

        local texture = icon:CreateTexture(nil, "ARTWORK")
        texture:SetTexture(TEST_ICONS[i % #TEST_ICONS + 1])
        if isDebuff then
            local border = icon:CreateTexture(nil, "BACKGROUND")
            border:SetAllPoints()
            border:SetColorTexture(unpack(TEST_DEBUFF_COLORS[i % #TEST_DEBUFF_COLORS + 1]))
            texture:SetPoint("TOPLEFT", 1, -1)
            texture:SetPoint("BOTTOMRIGHT", -1, 1)
        else
            texture:SetAllPoints()
        end
        StyleAuraIcon(icon, texture)

        local cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetCountdownFont("MyUIAuraTimerFont")
        table.insert(frame.cooldowns, cooldown)

        -- Stack counts on some of them
        if i % 3 == 0 then
            local count = cooldown:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
            count:SetPoint("BOTTOMRIGHT", 2, -2)
            count:SetText(tostring(i % 5 + 2))
        end
    end

    return frame
end

function ns.ToggleTestMode()
    if not testFrame then
        testFrame = CreateTestFrame()
    elseif testFrame:IsShown() then
        testFrame:Hide()
        return
    end
    testFrame:Show()
    -- Restart the spirals with different remaining times
    for i, cooldown in ipairs(testFrame.cooldowns) do
        cooldown:SetCooldown(GetTime(), 20 + i * 15)
    end
end
