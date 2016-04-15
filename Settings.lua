-- SlightlyImprovedAttributeBars 2.0.0
-- Licensed under CC BY-NC-SA 4.0

local NAMESPACE = "SlightlyImprovedAttributeBars"

local addOnSettings = CustomSettings:New(NAMESPACE)

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
        getFunc = function() return addOnSettings:Get("forceAlwaysShow") end,
        setFunc = function(value) addOnSettings:Set("forceAlwaysShow", value) end,
    },
    {
        type = "checkbox",
        name = "Show bar percentage",
        tooltip = "Display the percentage value on top of attribute bars and target's health.",
        getFunc = function() return addOnSettings:Get("showBarText") end,
        setFunc = function(value) addOnSettings:Set("showBarText", value) end,
    },
}

CALLBACK_MANAGER:RegisterCallback("SlightlyImprovedAttributeBars_OnAddOnLoaded", function()
    local LAM = LibStub("LibAddonMenu-2.0")
    LAM:RegisterAddonPanel(NAMESPACE, panel)
    LAM:RegisterOptionControls(NAMESPACE, options)
end)
