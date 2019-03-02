-- Slightly Improved™ Attribute Bars
-- The MIT License © 2017 Arthur Corenzan

local NAMESPACE = "SlightlyImprovedAttributeBars"

--
--
--

-- Add the percentage sign to the existing format string for absolute value and percentage.
SafeAddString(SI_ATTRIBUTE_NUMBERS_WITH_PERCENT, "<<1>> (<<2>>%)")

-- ZeniMax pulled a lazy one here and used the same format string
-- for both the absolute value and percentage only. The thing is
-- a "%" isn't added and I think it's bad design. So now I have to
-- override the whole function just to add an extra character at
-- the end of one string. Sight...
--
-- Originally found at EsoUI/Ingame/Globals/Globals.lua:81.
function ZO_FormatResourceBarCurrentAndMax(current, maximum)
    local returnValue = ""

    local percent = 0
    if maximum ~= 0 then
        percent = (current/maximum) * 100
        if percent < 10 then
            percent = ZO_CommaDelimitDecimalNumber(zo_roundToNearest(percent, .1))
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

-- Originally found at EsoUI/Ingame/PlayerAttributeBars/PlayerAttributeBars.lua:375.
local ATTRIBUTE_BAR_EXPANDED_WIDTH = 323

-- Minimum space between attribute bars.
local ATTRIBUTE_BAR_GUTTER = 30

-- Update attribute bars offsetX based on the shift set in settings.
local function UpdateAttributeBarsOffsetX(value)
    -- A smaller offset would overlap the bars.
    local minOffsetX = ATTRIBUTE_BAR_GUTTER

    -- A larger offset would move the bar outset of the screen.
    local maxOffsetX = (GuiRoot:GetWidth() - ATTRIBUTE_BAR_EXPANDED_WIDTH) / 2 - ATTRIBUTE_BAR_EXPANDED_WIDTH - ATTRIBUTE_BAR_GUTTER

    -- Convert from -100..+100 range to actual UI unit range.
    local offsetX = (value + 100) * (maxOffsetX - minOffsetX) / 200 + minOffsetX

    -- Health bar is centered so we don't touch it.
    -- Magicka bar is to the left. and since the UI plane goes left to
    -- right we apply a negative version of the new calculated offsetX.
    ZO_PlayerAttributeMagicka:ClearAnchors()
    ZO_PlayerAttributeMagicka:SetAnchor(RIGHT, ZO_PlayerAttributeHealth, LEFT, -offsetX, 0)

    -- Stamina bar is to the right so we can just set the new offsetX.
    ZO_PlayerAttributeStamina:ClearAnchors()
    ZO_PlayerAttributeStamina:SetAnchor(LEFT, ZO_PlayerAttributeHealth, RIGHT, offsetX, 0)
end

--
--
--

local targetUnitFrameOffsetY =
{
    ["Top"] = 88,
    ["Bottom"] = -288,
}

local targetUnitFramePoint =
{
    ["Top"] = TOP,
    ["Bottom"] = BOTTOM,
}

local playerToPlayerOffsetY =
{
    ["Top"] = -285,
    ["Bottom"] = -395,
}

-- Here we use table maps to know which offsetY or anchor point to use in each
-- available position. Also we have to move the player-to-player prompt up bit
-- so it doesn't overlap with the target's unit frame new position.
--
local function UpdateTargetUnitFramePosition(option, inCombat)
    if (option == "Automatic") then
        if (inCombat) then
            option = "Bottom"
        else
            option = "Top"
        end
    end

    local targetUnitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
    targetUnitFrame.frame:ClearAnchors()
    targetUnitFrame.frame:SetAnchor(targetUnitFramePoint[option], GuiRoot, nil, 0, targetUnitFrameOffsetY[option])

    PLAYER_TO_PLAYER.container:ClearAnchors()
    PLAYER_TO_PLAYER.container:SetAnchor(BOTTOM, PLAYER_TO_PLAYER.control, nil, 0, playerToPlayerOffsetY[option])
end

--
--
--

local defaultSavedVars =
{
    switchTargetUnitFramePosition = "Top",
    preventBuffedHealthFromFading = true,
    attributeBarsOffsetXShift = 0,
}

CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnSavedVarChanged", function(key, newValue, previousValue)
    if (key == "switchTargetUnitFramePosition") then
        UpdateTargetUnitFramePosition(newValue)
    elseif (key == "attributeBarsOffsetXShift") then
        UpdateAttributeBarsOffsetX(newValue)
    end
end)

CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnAddOnLoaded", function(savedVars)
    local function OnPlayerActivated()

        -- Change font of the bar labels and refresh their values.
        for _, i in ipairs({1, 3, 5}) do
            local attributeBar = PLAYER_ATTRIBUTE_BARS.bars[i]
            attributeBar.control.resourceNumbersLabel:SetFont("ZoFontWinH4")
            attributeBar:UpdateResourceNumbersLabel(attributeBar.current, attributeBar.effectiveMax)
        end

        -- Change font of the target's health bar as well.
        local unitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
        unitFrame.healthBar.resourceNumbersLabel:SetFont("ZoFontWinH4")

        UpdateTargetUnitFramePosition(savedVars.switchTargetUnitFramePosition)
        UpdateAttributeBarsOffsetX(savedVars.attributeBarsOffsetXShift)

        -- Here we prevent the health bar from fading when a buff is applied to our health
        -- such as armor or shield. Extended health due to food comsuption doesn't count.
        -- We seize the fact that attribute bars already have a mechanism
        -- in-place to prevent them from fading in other circunstances.
        do
            local healthBar = PLAYER_ATTRIBUTE_BARS.bars[1]

            -- Originally found at EsoUI/Ingame/UnitAttributeVisualizer/Modules/PowerShield.lua:117.
            local onPowerShieldUnitAttributeVisualAdded = ZO_UnitVisualizer_PowerShieldModule.OnUnitAttributeVisualAdded
            function ZO_UnitVisualizer_PowerShieldModule:OnUnitAttributeVisualAdded(...)
                onPowerShieldUnitAttributeVisualAdded(self, ...)
                if (savedVars.preventBuffedHealthFromFading) then
                    healthBar:AddForcedVisibleReference()
                end
            end

            -- Originally found at EsoUI/Ingame/UnitAttributeVisualizer/Modules/PowerShield.lua:133.
            local onPowerShieldUnitAttributeVisualRemoved = ZO_UnitVisualizer_PowerShieldModule.OnUnitAttributeVisualRemoved
            function ZO_UnitVisualizer_PowerShieldModule:OnUnitAttributeVisualRemoved(...)
                onPowerShieldUnitAttributeVisualRemoved(self, ...)
                if (savedVars.preventBuffedHealthFromFading) then
                    healthBar:RemoveForcedVisibleReference()
                end
            end

            -- Originally found at EsoUI/Ingame/UnitAttributeVisualizer/Modules/ArmorDamage.lua:250.
            local onArmorDamageUnitAttributeVisualAdded = ZO_UnitVisualizer_ArmorDamage.OnUnitAttributeVisualAdded
            function ZO_UnitVisualizer_ArmorDamage:OnUnitAttributeVisualAdded(...)
                onArmorDamageUnitAttributeVisualAdded(self, ...)
                if (savedVars.preventBuffedHealthFromFading) then
                    healthBar:AddForcedVisibleReference()
                end
            end

            -- Originally found at EsoUI/Ingame/UnitAttributeVisualizer/Modules/ArmorDamage.lua:260.
            local onArmorDamageUnitAttributeVisualRemoved = ZO_UnitVisualizer_ArmorDamage.OnUnitAttributeVisualRemoved
            function ZO_UnitVisualizer_ArmorDamage:OnUnitAttributeVisualRemoved(...)
                onArmorDamageUnitAttributeVisualRemoved(self, ...)
                if (savedVars.preventBuffedHealthFromFading) then
                    healthBar:RemoveForcedVisibleReference()
                end
            end
        end
    end
    EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    local function OnPlayerCombatState(eventCode, inCombat)
        UpdateTargetUnitFramePosition(savedVars.switchTargetUnitFramePosition, inCombat)
    end
    EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_COMBAT_STATE, OnPlayerCombatState)
end)

--
--
--

-- Add-on entrypoint. You should NOT need to edit below this line.
-- Make sure you have set a NAMESPACE variable and you're good to go.
--
-- If you need to hook into the AddOnLoaded event use the NAMESPACE.."_OnAddOnLoaded" callback. e.g.
-- CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnAddOnLoaded", function(savedVars)
--     ...
-- end)
--
-- To listen to saved variables being changed use the NAMESPACE.."_OnSavedVarChanged" callback. e.g.
-- CALLBACK_MANAGER:RegisterCallback(NAMESPACE.."_OnSavedVarChanged", function(key, newValue, previousValue)
--     ...
-- end)
--
EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_ADD_ON_LOADED, function(eventCode, addOnName)
    if (addOnName == NAMESPACE) then
        local savedVars = ZO_SavedVars:New(NAMESPACE.."_SavedVars", 2, nil, defaultSavedVars)
        do
            local t = getmetatable(savedVars)
            local __newindex = t.__newindex
            function t.__newindex(self, key, value)
                CALLBACK_MANAGER:FireCallbacks(NAMESPACE.."_OnSavedVarChanged", key, value, self[key])
                __newindex(self, key, value)
            end
        end
        CALLBACK_MANAGER:FireCallbacks(NAMESPACE.."_OnAddOnLoaded", savedVars)
    end
end)

