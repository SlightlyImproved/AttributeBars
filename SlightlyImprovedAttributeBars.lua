-- SlightlyImprovedAttributeBars 2.0.0
-- Licensed under CC BY-NC-SA 4.0

-- Uncomment to disable debug messages
-- local function d() end

local NAMESPACE = "SlightlyImprovedAttributeBars"

--
--
--

local addOnSettings = CustomSettings:New(NAMESPACE)

addOnSettings:RegisterForUpdate("forceAlwaysShow", function(value)
    PLAYER_ATTRIBUTE_BARS:ForceShow(value)
end)

addOnSettings:RegisterForUpdate("showBarText", function()
    local targetUnitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")
    targetUnitFrame:RefreshControls()
    for _, i in ipairs({1, 3, 5}) do
        local attributeBar = PLAYER_ATTRIBUTE_BARS.bars[i]
        attributeBar:UpdateStatusBar()
    end
end)

--
--
--

local function GetBarText(currentValue, maxValue)
    local isEnabled = addOnSettings:Get("showBarText")
    if isEnabled and currentValue and maxValue and maxValue > 0 then
        local percentage = zo_floor(currentValue / maxValue * 100)
        return string.format("%d%%", percentage)
    else
        return ""
    end
end

local function ImprovePlayerAttributeBars()
    -- Bars for Magicka, Health and Stamina
    for _, i in ipairs({1, 3, 5}) do
        local attributeBar = PLAYER_ATTRIBUTE_BARS.bars[i]

        if attributeBar.hasBeenImproved then return end
        attributeBar.hasBeenImproved = true

        local UpdateStatusBar = attributeBar.UpdateStatusBar
        attributeBar.UpdateStatusBar = function(self, ...)
            UpdateStatusBar(self, ...)
            if self.textEnabled then
                self.label:SetText(GetBarText(self.current, self.max))
            end
        end

        attributeBar:SetTextEnabled(true)
        attributeBar.label:SetFont("ZoFontGameLargeBold")
    end
end

local function ImproveTargetUnitFrame()
    local unitFrame = ZO_UnitFrames_GetUnitFrame("reticleover")

    if unitFrame.hasBeenImproved then return end
    unitFrame.hasBeenImproved = true

    local healthBar = unitFrame.healthBar
    local healthBarControl = healthBar.barControls[1]

    local healthBarLabel = CreateControlFromVirtual(healthBarControl:GetName().."Text", healthBarControl, "Siab_Label")
    healthBarLabel:SetText(GetBarText(healthBar.currentValue, healthBar.maxValue))
    healthBarLabel:SetAnchor(CENTER, nil, RIGHT, 0, 0)

    function healthBar:UpdateText(...)
        healthBarLabel:SetText(GetBarText(self.currentValue, self.maxValue))
    end
end

--
--
--

local defaultSavedVars =
{
    forceAlwaysShow = false,
    showBarText = false,
}

local function OnPlayerActivated()
    ImprovePlayerAttributeBars()
    ImproveTargetUnitFrame()
end

local function OnAddOnLoaded(event, addOnName)
    if (addOnName == NAMESPACE) then
        EVENT_MANAGER:UnregisterForEvent(NAMESPACE, EVENT_ADD_ON_LOADED)

        local savedVars = ZO_SavedVars:New("SlightlyImprovedAttributeBars_SavedVars", 1, nil, defaultSavedVars)
        addOnSettings = CustomSettings:New(NAMESPACE, savedVars)

        CALLBACK_MANAGER:FireCallbacks("SlightlyImprovedAttributeBars_OnAddOnLoaded")

        EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end

EVENT_MANAGER:RegisterForEvent(NAMESPACE, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
