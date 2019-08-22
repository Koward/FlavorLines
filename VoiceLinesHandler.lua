SpeechHandler = {}

--- Functions that tweaks the Display for our specific purpose


local TIME_BEFORE_DISPLAY = 1

function SpeechHandler:Proclaim(unitId, voiceLine)
    SpeechHandler:DisplayToast(unitId, voiceLine, AnimIDs.EmoteTalkExclamation, AnimIDs.EmoteTalk)
end

-- Sound can either be a SoundKit (number) or a CustomSound {path, duration}
local function GetVOParameters(sound)
    local isSoundKit = type(sound) == "number"
    if (isSoundKit) then
        return sound, nil
    else
        return unpack(sound)
    end
end

function SpeechHandler:DisplayToast(unitId, voiceLine, animIntro, animLoop)
    local name, _ = UnitName(unitId)

    if voiceLine == nil then
        print(string.format("Error: %s default locale could not be found.", lineId))
    end
    local text, sound = unpack(voiceLine)

    -- vo is either number (ID) or path
    local vo, lineDuration = GetVOParameters(sound)
    if type(vo) == "number" and not FlavorLinesConfig.voice then
        -- Without sound, cannot guess the soundkit duration so we attribute a default value
        lineDuration = 1.5
    end
    if FlavorLinesConfig.frame then
        FlavorHeadData:SetCurrentLineInfo(lineDuration, name, text, true, 0)
        FlavorHeadData:SetCurrentLineAnimationInfo(0, animIntro, animLoop, lineDuration)
        FlavorHeadFrame_PrepareModel(unitId)
    end

    local message -- Needs to be computed immediately because unitId is only available now, not later.
    if FlavorLinesConfig.text then
        local unitName, _ = UnitName(unitId)
        message = string.format("%s says: %s", unitName, text)
    end

    local timer = C_Timer.NewTimer(TIME_BEFORE_DISPLAY, function()
        WatchForUnitDeath:stop()
        if FlavorLinesConfig.frame then
            FlavorHeadFrame_PlayCurrent()
        end
        if (FlavorLinesConfig.voice and vo) then
            local success, voHandle = FlavorDisplay:PlayVoiceOver(vo)
            if (success) then
                FlavorHeadFrame.voHandle = voHandle;
            end
        end
        if FlavorLinesConfig.text then
            FlavorDisplay:PrintCreatureMessage(message)
        end
    end)

    WatchForUnitDeath:start(UnitGUID(unitId), function()
        timer:Cancel()
    end)
end

WatchForUnitDeath = CreateFrame("FRAME")
function WatchForUnitDeath:start(enemyGUID, func)
    WatchForUnitDeath:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    WatchForUnitDeath:SetScript("OnEvent", function(self, event)
        if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
            local _, type, _, _, _, _, _, destGUID, _, _, _ = CombatLogGetCurrentEventInfo()
            if (type == "UNIT_DIED" and destGUID == enemyGUID) then
                func()
                WatchForUnitDeath:stop()
            end
        end
    end)
end

function WatchForUnitDeath:stop()
    WatchForUnitDeath:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

