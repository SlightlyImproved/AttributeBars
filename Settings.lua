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
        name = "Switch Target's Frame Position",
        tooltip = "Switch the target's Health bar position from the top to the bottom of screen. Automatic will only do the switch during combat.",
        choices = {"Never", "Always", "Automatic"},
        getFunc = function() return settings.switchTargetFramePosition end,
        setFunc = function(value) settings.switchTargetFramePosition = value end,
    },
    {
        type = "checkbox",
        name = "Prevent Shielded Health From Fading",
        tooltip = "Prevent the Health bar from fading while shield or damage absorption effect are active.",
        getFunc = function() return settings.keepShieldedHealthShowing end,
        setFunc = function(value) settings.keepShieldedHealthShowing = value end,
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
