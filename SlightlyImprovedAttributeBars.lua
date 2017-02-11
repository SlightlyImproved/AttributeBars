-- Slightly Improved™ Attribute Bars 2.1.0 (Feb 10 2017)
-- Licensed under MIT © 2017 Arthur Corenzan

-- Uncomment to disable debug messages
local function d() end
local function df() end

local NAMESPACE = "SlightlyImprovedAttributeBars"

--
--
--

-- Override default format
SafeAddString(SI_ATTRIBUTE_NUMBERS_WITH_PERCENT, "<<1>> (<<2>>%)")

-- Override esoui/ingame/globals/globals.lua:119
function ZO_FormatResourceBarCurrentAndMax(current, maximum)
    local returnValue = ""

    local percent = 0
    if maximum ~= 0 then
        percent = (current/maximum) * 100
        if percent < 10 then
            percent = ZO_LocalizeDecimalNumber(zo_roundToNearest(percent, .1))
        else
            percent = zo_round(percent)
        end
    end

    local setting = tonumber(GetSetting(SETTING_TYPE_UI, UI_SETTING_RESOURCE_NUMBERS))
    if setting == RESOURCE_NUMBERS_SETTING_NUMBER_ONLY then
        returnValue = zo_strformat(SI_ATTRIBUTE_NUMBERS_WITHOUT_PERCENT, ZO_LocalizeDecimalNumber(current))
    elseif setting == RESOURCE_NUMBERS_SETTING_PERCENT_ONLY then
        returnValue = zo_strformat(SI_ATTRIBUTE_NUMBERS_WITHOUT_PERCENT, percent).."%"
    elseif setting == RESOURCE_NUMBERS_SETTING_NUMBER_AND_PERCENT then
        returnValue = zo_strformat(SI_ATTRIBUTE_NUMBERS_WITH_PERCENT, ZO_LocalizeDecimalNumber(current), percent)
    end

    return returnValue
end

--
--
--

local function ImprovePlayerAttributeBars(forceAlwaysShow)
    PLAYER_ATTRIBUTE_BARS:ForceShow(forceAlwaysShow)
    -- Bars for Magicka, Health and Stamina
    for _, i in ipairs({1, 3, 5}) do
        local attributeBar = PLAYER_ATTRIBUTE_BARS.bars[i]
        attributeBar.control.resourceNumbersLabel:SetFont("SiabFont")
    end
end

local TARGET_UNIT_FRAME_OFFSET_OPTIONS =
{
    ["Top"] = 88,
    ["Bottom"] = 788,
}

local PLAYER_TO_PLAYER_OFFSET_OPTIONS =
{
    ["Top"] = -285,
    ["Bottom"] = -385,
}

local function ImproveTargetUnitFrame(position)
    local unitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
    unitFrame.healthBar.resourceNumbersLabel:SetFont("SiabFont")

    local anchor = ZO_Anchor:New()

    anchor:SetFromControlAnchor(unitFrame.frame, 0)
    anchor:SetOffsets(nil, TARGET_UNIT_FRAME_OFFSET_OPTIONS[position])
    anchor:Set(unitFrame.frame)

    anchor:SetFromControlAnchor(PLAYER_TO_PLAYER.container, 0)
    anchor:SetOffsets(nil, PLAYER_TO_PLAYER_OFFSET_OPTIONS[position])
    anchor:Set(PLAYER_TO_PLAYER.container)
end

--
--
--

local defaultSavedVars =
{
    forceAlwaysShow = false,
    targetFramePosition = "Top",
}

local function OnAddOnLoaded(event, addOnName)
    if (addOnName == NAMESPACE) then
        local savedVars = ZO_SavedVars:New(NAMESPACE.."_SavedVars", 1, nil, defaultSavedVars)

        do
            local mt = getmetatable(savedVars)
            local __newindex = mt.__newindex
            function mt.__newindex(self, key, value)
                __newindex(self, key, value)
                if (key == "forceAlwaysShow") then
                    PLAYER_ATTRIBUTE_BARS:ForceShow(value)
                    for _, i in ipairs({1, 3, 5}) do
                        local bar = PLAYER_ATTRIBUTE_BARS.bars[i]
                        bar:UpdateStatusBar()
                    end
                end
                if (key == "targetFramePosition") then
                    ImproveTargetUnitFrame(savedVars.targetFramePosition)
                end
            end
        end

        local function OnPlayerActivated()
            ImprovePlayerAttributeBars(savedVars.forceAlwaysShow)
            ImproveTargetUnitFrame(savedVars.targetFramePosition)
        end
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

        local function OnInterfaceSettingsChanged()
            if savedVars.forceAlwaysShow then
                for _, i in ipairs({1, 3, 5}) do
                    local bar = PLAYER_ATTRIBUTE_BARS.bars[i]
                    bar:UpdateResourceNumbersLabel(bar.current, bar.effectiveMax)
                end
            end
        end
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_INTERFACE_SETTING_CHANGED, OnInterfaceSettingsChanged)

        CALLBACK_MANAGER:FireCallbacks(NAMESPACE.."_OnAddOnLoaded", savedVars)
    end
end

EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
