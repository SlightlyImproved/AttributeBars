-- Slightly Improved™ Attribute Bars 2.1.0 (Feb 10 2017)
-- Licensed under MIT © 2017 Arthur Corenzan

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
        type = "checkbox",
        name = "Always show attribute bars",
        tooltip = "Prevent the Stamina, Magicka and Health bars from fading off.",
        getFunc = function() return settings.forceAlwaysShow end,
        setFunc = function(value) settings.forceAlwaysShow = value end,
    },
    {
        type = "dropdown",
        name = "Target unit frame position",
        tooltip = "Displace your target's unit frame vertically. Top is the default position. Bottom is right above your Magicka, Health and Stamina bars.",
        choices = {"Top", "Bottom"},
        getFunc = function() return settings.targetFramePosition end,
        setFunc = function(value) settings.targetFramePosition = value end,
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
