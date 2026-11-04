local _, ns = ...

-- All UI settings live here. Edit values, then /reload in game.
--
-- Keys are the global names of Blizzard's frames (use /fstack in game to find them).
-- Positions of frames that Edit Mode manages are written into the addon's Edit Mode layout.
-- point = { point, relativeTo, relativePoint, x, y }  -- same arguments as Frame:SetPoint
ns.config = {
    -- Distance of the lowest bag window from the bottom of the screen (Blizzard's default: 85)
    bagsOffsetY = 200,

    frames = {
        -- Status bars (experience, reputation, ...), then action bars 1, 2 and 3 stacked on top
        MainStatusTrackingBarContainer = {
            point = { "BOTTOM", "UIParent", "BOTTOM", 0, 0 },
            scale = 0.9,
        },
        SecondaryStatusTrackingBarContainer = {
            point = { "BOTTOM", "MainStatusTrackingBarContainer", "TOP", 0, 0 },
            scale = 0.9,
        },
        MainActionBar = {
            point = { "BOTTOM", "SecondaryStatusTrackingBarContainer", "TOP", 0, 0 },
        },
        MultiBarBottomLeft = {
            point = { "BOTTOM", "MainActionBar", "TOP", 0, 0 },
        },
        MultiBarBottomRight = {
            point = { "BOTTOM", "MultiBarBottomLeft", "TOP", 0, 0 },
        },

        -- Cast bar above the action bars
        PlayerCastingBarFrame = {
            -- spacing of 25 to account for the spell name that shows up below the bar
            point = { "CENTER", "UIParent", "CENTER", 0, -170 },
        },

        -- Stance bar in the bottom left corner, exit vehicle button on top of it
        StanceBar = {
            point = { "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0 },
        },
        MainMenuBarVehicleLeaveButton = {
            point = { "BOTTOMLEFT", "StanceBar", "TOPLEFT", 0, 0 },
        },

        -- Chat window above the player frame
        ChatFrame1 = {
            point = { "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 32, 80 },
        },

        -- Menu buttons (character, spellbook, ...)
        MicroMenuContainer = {
            point = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", 0, 0 },
        },

        -- Player and target on top of action bar 3, each sticking out by half its width (110)
        -- past the bar's edge, so pet and target of target fit in below them, next to the bar
        PlayerFrame = {
            point = { "RIGHT", "UIParent", "CENTER", -150, -150 },
            scale = 1.2,
        },
        TargetFrame = {
            point = { "LEFT", "UIParent", "CENTER", 150, -150 },
            scale = 1.2,
        },
        TargetFrameToT = {
            point = { "TOPRIGHT", "TargetFrame", "BOTTOMRIGHT", 0, -8 },
        },
        FocusFrame = {
            point = { "BOTTOMRIGHT", "PlayerFrame", "TOPRIGHT", 0, 8 },
            scale = 1.0,
        },
        PetFrame = {
            point = { "TOPLEFT", "PlayerFrame", "BOTTOMLEFT", 0, -8 },
            scale = 1.0,
        },
    },
}
