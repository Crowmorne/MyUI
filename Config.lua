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
            point = { "BOTTOM", "MultiBarBottomRight", "TOP", 0, 20 },
        },

        -- Stance bar in the bottom left corner, exit vehicle button on top of it
        StanceBar = {
            point = { "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 0, 0 },
        },
        MainMenuBarVehicleLeaveButton = {
            point = { "BOTTOMLEFT", "StanceBar", "TOPLEFT", 0, 0 },
        },

        -- Menu buttons (character, spellbook, ...)
        MicroMenuContainer = {
            point = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", 0, 0 },
        },

        PlayerFrame = {
            point = { "CENTER", "UIParent", "CENTER", -250, -150 },
            scale = 1.2,
        },
        TargetFrame = {
            point = { "CENTER", "UIParent", "CENTER", 250, -150 },
            scale = 1.0,
        },
        PetFrame = {
            point = { "TOPLEFT", "PlayerFrame", "BOTTOMLEFT", 60, 0 },
            scale = 1.0,
        },
    },
}
