-- SlightlyImprovedAttributeBars 2.0.0
-- Licensed under CC BY-NC-SA 4.0

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
    }
    -- {
    --     type = "checkbox",
    --     name = "Show bar percentage",
    --     tooltip = "Display the percentage value on top of attribute bars and target's health.",
    --     getFunc = function() return addOnSettings:Get("showBarText") end,
    --     setFunc = function(value) addOnSettings:Set("showBarText", value) end,
    -- },
}

CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnAddOnLoaded", function(savedVars)
    settings = savedVars

    local LAM = LibStub("LibAddonMenu-2.0")
    LAM:RegisterAddonPanel(NAMESPACE, panel)
    LAM:RegisterOptionControls(NAMESPACE, options)
end)
