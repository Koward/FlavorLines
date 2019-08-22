local function FindVoiceSet(unitId)
    local _, _, _, _, _, npc_id_str, _ = string.split("-", UnitGUID(unitId));
    local npcId = tonumber(npc_id_str)
    local mapping = CreatureScriptsMappings[npcId]
    if mapping then
        local lines = mapping.lines
        local chance = mapping.chance or 30 -- default
        local named = mapping.named or false
        if type(lines) == "function" then
            local final_lines = lines(unitId)
            return final_lines, chance, named
        else
            return lines, chance, named
        end
    end
    return nil, 0, false
end


OnBattleStarted:AddListener(function(unitId)
    local type, _, _, _, _, _, _ = string.split("-", UnitGUID(unitId));
    if type ~= "Creature" then
        -- Prevents triggering for players, for example.
        return
    end
    -- TODO Idea:if named then use headframe, otherwise just text
    local lines, chance, named = FindVoiceSet(unitId)
    if lines ~= nil and getn(lines) > 0 then
        if (math.random(100) <= chance) then
            local voiceLine = lines[math.random(#lines)]
            SpeechHandler:Proclaim(unitId, voiceLine)
        else
            --FIXME DEBUG
            print("<This would not have been played in true conditions>")
            local voiceLine = lines[math.random(#lines)]
            SpeechHandler:Proclaim(unitId, voiceLine)
        end
--[[    else
        -- FIXME DEBUG
        print("<Default voiceline>")
        local voiceLine = VoiceLinesDatabase.Debug
        SpeechHandler:Proclaim(unitId, voiceLine)]]
    end
end)

