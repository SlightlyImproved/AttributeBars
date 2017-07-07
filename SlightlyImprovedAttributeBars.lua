-- Slightly Improved™ Attribute Bars
-- The MIT License © 2017 Arthur Corenzan

-- Uncomment to disable debug messages
local function d() end
local function df() end

local NAMESPACE = "SlightlyImprovedAttributeBars"
local savedVars = {}

--
--
--

-- Override default format
SafeAddString(SI_ATTRIBUTE_NUMBERS_WITH_PERCENT, "<<1>> (<<2>>%)")

-- Override esoui/ingame/globals/globals.lua:123
function ZO_FormatResourceBarCurrentAndMax(current, maximum)
    local returnValue = ""

    local percent = 0
    if maximum ~= 0 then
        percent = (current / maximum) * 100
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

local function ImprovePlayerAttributeBars()
    -- Bars for Magicka, Health and Stamina
    for _, i in ipairs({1, 3, 5}) do
        local attributeBar = PLAYER_ATTRIBUTE_BARS.bars[i]
        attributeBar.control.resourceNumbersLabel:SetFont("SiabFont")
        attributeBar:UpdateResourceNumbersLabel(attributeBar.current, attributeBar.effectiveMax)
    end
end


local DEFAULT_MAGICKA_BAR_OFFSET_X =  237
local DEFAULT_STAMINA_BAR_OFFSET_X = -237

local function ApplyAttributeBarsOffsetXShift(shift)
    local anchor = ZO_Anchor:New()

    anchor:SetFromControlAnchor(ZO_PlayerAttributeMagicka, 0)
    anchor:SetOffsets(DEFAULT_MAGICKA_BAR_OFFSET_X - shift)
    anchor:Set(ZO_PlayerAttributeMagicka)

    anchor:SetFromControlAnchor(ZO_PlayerAttributeStamina, 0)
    anchor:SetOffsets(DEFAULT_STAMINA_BAR_OFFSET_X + shift)
    anchor:Set(ZO_PlayerAttributeStamina)
end

local TARGET_UNIT_FRAME_OFFSET_OPTIONS =
{
    ["Top"] = 88,
    ["Bottom"] = 742,
}

local PLAYER_TO_PLAYER_OFFSET_OPTIONS =
{
    ["Top"] = -285,
    ["Bottom"] = -385,
}

local function ImproveTargetUnitFrame()
    local unitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
    unitFrame.healthBar.resourceNumbersLabel:SetFont("SiabFont")
end

local function SwitchTargetFramePosition(position)
    local unitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
    local anchor = ZO_Anchor:New()

    anchor:SetFromControlAnchor(unitFrame.frame, 0)
    anchor:SetOffsets(nil, TARGET_UNIT_FRAME_OFFSET_OPTIONS[position])
    anchor:Set(unitFrame.frame)

    anchor:SetFromControlAnchor(PLAYER_TO_PLAYER.container, 0)
    anchor:SetOffsets(nil, PLAYER_TO_PLAYER_OFFSET_OPTIONS[position])
    anchor:Set(PLAYER_TO_PLAYER.container)
end

local function PreventShieldedHealthBarFade()
    local healthBar = PLAYER_ATTRIBUTE_BARS.bars[1]

    local onPowerShieldUnitAttributeVisualAdded = ZO_UnitVisualizer_PowerShieldModule.OnUnitAttributeVisualAdded
    function ZO_UnitVisualizer_PowerShieldModule:OnUnitAttributeVisualAdded(...)
        onPowerShieldUnitAttributeVisualAdded(self, ...)
        if (savedVars.keepShieldedHealthShowing) then
            healthBar:AddForcedVisibleReference()
        end
    end

    local onPowerShieldUnitAttributeVisualRemoved = ZO_UnitVisualizer_PowerShieldModule.OnUnitAttributeVisualRemoved
    function ZO_UnitVisualizer_PowerShieldModule:OnUnitAttributeVisualRemoved(...)
        onPowerShieldUnitAttributeVisualRemoved(self, ...)
        if (savedVars.keepShieldedHealthShowing) then
            healthBar:RemoveForcedVisibleReference()
        end
    end

    local onArmorDamageUnitAttributeVisualAdded = ZO_UnitVisualizer_ArmorDamage.OnUnitAttributeVisualAdded
    function ZO_UnitVisualizer_ArmorDamage:OnUnitAttributeVisualAdded(...)
        onArmorDamageUnitAttributeVisualAdded(self, ...)
        if (savedVars.keepShieldedHealthShowing) then
            healthBar:AddForcedVisibleReference()
        end
    end

    local onArmorDamageUnitAttributeVisualRemoved = ZO_UnitVisualizer_ArmorDamage.OnUnitAttributeVisualRemoved
    function ZO_UnitVisualizer_ArmorDamage:OnUnitAttributeVisualRemoved(...)
        onArmorDamageUnitAttributeVisualRemoved(self, ...)
        if (savedVars.keepShieldedHealthShowing) then
            healthBar:RemoveForcedVisibleReference()
        end
    end
end

--
--
--

local defaultSavedVars =
{
    switchTargetFramePosition = "Never",
    keepShieldedHealthShowing = true,
    attributeBarsOffsetXShift = 0,
}

local function OnAddOnLoaded(event, addOnName)
    if (addOnName == NAMESPACE) then
        savedVars = ZO_SavedVars:New(NAMESPACE.."_SavedVars", 1, nil, defaultSavedVars)

        do
            local mt = getmetatable(savedVars)
            local __newindex = mt.__newindex
            function mt.__newindex(self, key, value)
                __newindex(self, key, value)
                if (key == "targetFramePosition") then
                    if (value == "Always") or (value == "Automatic" and IsUnitInCombat("player")) then
                        SwitchTargetFramePosition("Bottom")
                    else
                        SwitchTargetFramePosition("Top")
                    end
                end
                if (key == "attributeBarsOffsetXShift") then
                    ApplyAttributeBarsOffsetXShift(savedVars.attributeBarsOffsetXShift)
                end
            end
        end

        local function OnPlayerActivated()
            ImprovePlayerAttributeBars()
            ImproveTargetUnitFrame()
            if (savedVars.switchTargetFramePosition == "Always") then
                SwitchTargetFramePosition("Bottom")
            end
            ApplyAttributeBarsOffsetXShift(savedVars.attributeBarsOffsetXShift)
            PreventShieldedHealthBarFade()
        end
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

        local function OnPlayerCombatState(eventCode, inCombat)
            if (savedVars.switchTargetFramePosition == "Automatic") then
                SwitchTargetFramePosition(inCombat and "Bottom" or "Top")
            end
        end
        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)

        CALLBACK_MANAGER:FireCallbacks(NAMESPACE.."_OnAddOnLoaded", savedVars)
    end
end

EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
