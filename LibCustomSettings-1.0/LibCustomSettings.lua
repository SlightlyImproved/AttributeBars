-- LibCustomSettings 1.0.0
-- Licensed under CC BY-NC-SA 4.0

CustomSettings = ZO_Object:Subclass()

local settingsTable = {}
local callbackManager = ZO_CallbackObject:New()

local function RegisterCallback(addOnName, settingName, callback)
    local name = addOnName..":"..settingName
    callbackManager:RegisterCallback(name, callback)
end

local function FireCallbacks(addOnName, settingName, ...)
    local name = addOnName..":"..settingName
    callbackManager:FireCallbacks(name, ...)
end

function CustomSettings:New(name, savedVars)
    local settings = settingsTable[name]
    if (not settings) then
        settings = ZO_Object.New(self)
        settings.name = name
        settings.savedVars = {}
        settingsTable[name] = settings
    end
    settings:SetSavedVars(savedVars)
    return settings
end

function CustomSettings:SetSavedVars(savedVars)
    if savedVars then
        self.savedVars = savedVars
        for key, _ in pairs(self.savedVars.default) do
            local value = self.savedVars[key]
            FireCallbacks(self.name, key, value)
        end
    end
end

function CustomSettings:Set(name, value)
    local previousValue = self.savedVars[name]
    self.savedVars[name] = value
    FireCallbacks(self.name, name, value, previousValue)
end

function CustomSettings:Get(name)
    return self.savedVars[name]
end

function CustomSettings:RegisterForUpdate(name, callback)
    RegisterCallback(self.name, name, callback)
end
