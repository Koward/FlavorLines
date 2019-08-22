local folderName, L = ...
local addonName = folderName

local defaultConfig = {
    version = 1, -- In case format changes
    voice = true,
    text = true,
    frame = true,
}

--- ConfigA <= ConfigB
local copyConfig = function(configA, configB)
    configA.version = configB.version
    configA.voice = configB.voice
    configA.text = configB.text
    configA.frame = configB.frame
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Our saved variables, if they exist, have been loaded at this point.
        if FlavorLinesConfig == nil then
            FlavorLinesConfig = {}
            copyConfig(FlavorLinesConfig, defaultConfig)
        end
    end
end)
frame.name = addonName
frame:Hide()
local temporaryConfig = {}
--frame.default = function() copyConfig(temporaryConfig, defaultConfig) end

function FlavorLinesConfig_OnLoad(frame)
    -- Greatly inspired by BugSack's config.lua
    local function newCheckbox(label, description, onClick)
        local check = CreateFrame("CheckButton", addonName.."Check" .. label, frame, "InterfaceOptionsCheckButtonTemplate")
        check:SetScript("OnClick", function(self)
            local tick = self:GetChecked()
            if tick then -- FIXME DEBUG, At some point checkboxes does not visually update themselves
                print("Ticked")
            else
                print("Unticked")
            end
            onClick(self, tick and true or false)
            if tick then
                PlaySound(856) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
            else
                PlaySound(857) -- SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF
            end
        end)
        check.label = _G[check:GetName() .. "Text"]
        check.label:SetText(label)
        check.tooltipText = label
        check.tooltipRequirement = description
        return check
    end

    copyConfig(temporaryConfig, FlavorLinesConfig)
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(addonName)

    local voiceSetting = newCheckbox(
            L.configVoice,
            L.configVoiceDesc,
            function(self, value) temporaryConfig.voice = value end)
    voiceSetting:SetChecked(temporaryConfig.voice)
    voiceSetting:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -2, -16)

    local textSetting = newCheckbox(
            L.configText,
            L.configTextDesc,
            function(self, value) temporaryConfig.text = value end)
    textSetting:SetChecked(temporaryConfig.text)
    textSetting:SetPoint("TOPLEFT", voiceSetting, "BOTTOMLEFT", -2, -8)

    local frameSetting = newCheckbox(
            L.configFrame,
            L.configFrameDesc,
            function(self, value) temporaryConfig.frame = value end)
    frameSetting:SetChecked(temporaryConfig.frame)
    frameSetting:SetPoint("TOPLEFT", textSetting, "BOTTOMLEFT", -2, -8)

    frame.okay = function(self) copyConfig(FlavorLinesConfig, temporaryConfig) end
    frame.default = function(self)
        voiceSetting:SetChecked(true)
        textSetting:SetChecked(true)
        frameSetting:SetChecked(true)
        copyConfig(temporaryConfig, defaultConfig)
    end

    frame:SetScript("OnShow", nil)
end

frame:SetScript("OnShow", FlavorLinesConfig_OnLoad)
InterfaceOptions_AddCategory(frame)

