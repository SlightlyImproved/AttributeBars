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
        name = "Target's Health Bar Position",
        tooltip = "Controls whether to display the target's Health Bar on the top or the bottom of the screen. Automatic will switch to the bottom only during combat.",
        choices = {"Top", "Bottom", "Automatic"},
        getFunc = function() return settings.switchTargetUnitFramePosition end,
        setFunc = function(value) settings.switchTargetUnitFramePosition = value end,
    },
    {
        type = "checkbox",
        name = "Shielded/Armored Health Visiblity",
        tooltip = "Prevent the Health Bar from fading while shield or damage absorption effects are active.",
        getFunc = function() return settings.preventBuffedHealthFromFading end,
        setFunc = function(value) settings.preventBuffedHealthFromFading = value end,
    },
    {
        type = "slider",
        name = "Attribute Bars Horizontal Shift",
        tooltip = "Displace Magicka, Health, and Stamina bars either further apart or closer together.",
        min = -100,
        max = 100,
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
