-- Slightly Improved™ Attribute Bars
-- The MIT License © 2017 Arthur Corenzan

local NAMESPACE = "SlightlyImprovedAttributeBars"

local settings = {}

local panel =
{
    type = "panel",
    name = "Slightly Improved™ Attribute Bars",
    displayName = "Slightly Improved™ Attribute Bars",
    author = nil,
    version = nil,
}

local options =
{
    {
        type = "dropdown",
        name = "Default Target's Frame Position",
        tooltip = "Displace your target's unit frame vertically. Top is the default position. Bottom is right above your Magicka, Health and Stamina bars.",
        choices = {"Top", "Bottom"},
        getFunc = function() return settings.targetFramePosition end,
        setFunc = function(value) settings.targetFramePosition = value end,
    },
    {
        type = "checkbox",
        name = "Switch Target's Frame Position in Combat",
        tooltip = "Checking this will make target's frame switch position temporarily during combat.",
        getFunc = function() return settings.switchTargetFramePositionInCombat end,
        setFunc = function(value) settings.switchTargetFramePositionInCombat = value end,
    },
    {
        type = "slider",
        name = "Attribute Bars Horizontal Shift",
        tooltip = "Displace Magicka, Health, and Stamina bars either further apart or closer together.",
        min = -80,
        max = 280,
        step = 10,
        getFunc = function() return settings.attributeBarsOffsetXShift end,
        setFunc = function(value) settings.attributeBarsOffsetXShift = value end,
    },
}

CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnAddOnLoaded", function(savedVars)
    settings = savedVars

    local LAM = LibStub("LibAddonMenu-2.0")
    LAM:RegisterAddonPanel(NAMESPACE, panel)
    LAM:RegisterOptionControls(NAMESPACE, options)
end)
