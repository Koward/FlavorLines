-- A "Battle" starts by entering combat with the first enemy.
-- Multiple enemies might be aggroed during the same battle, but one event only will be triggered.

OnBattleStarted = {}
function OnBattleStarted:PlayListeners(unitId)
    for _, listener in ipairs(OnBattleStarted) do
        listener(unitId)
    end
end

function OnBattleStarted:AddListener(func)
    table.insert(OnBattleStarted, func)
end

-- TODO Give time elapsed since actual start.
-- TODO Indeed, there can be some time before combat begin and full enemy identification

local enemyGUID

local eventFrame = CreateFrame("FRAME");
local function ClearEnemyAndEvents()
    enemyGUID = nil
    eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    eventFrame:UnregisterEvent("PLAYER_TARGET_CHANGED")
end
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
eventFrame:SetScript("OnEvent", function(_, event)
    if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
        local timestamp, type, hideCaster,
        sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

        if (enemyGUID == nil) then
            local damageOrDamageAttempt = type == "SWING_DAMAGE" or
                    type == "RANGE_DAMAGE" or
                    type == "SPELL_DAMAGE"

            local justFoundEnemy = false
            if (damageOrDamageAttempt) then
                local playerGUID = UnitGUID("player")
                if (destGUID == playerGUID and sourceGUID) then
                    enemyGUID = sourceGUID
                    justFoundEnemy = true
                elseif (sourceGUID == playerGUID and destGUID) then
                    enemyGUID = destGUID
                    justFoundEnemy = true
                end
            end

            if (justFoundEnemy) then
                -- TODO Also find as mouseover ?
                if (UnitGUID("target") == enemyGUID) then
                    OnBattleStarted:PlayListeners("target")
                    ClearEnemyAndEvents()
                else
                    -- Still need to find the enemy as target
                    eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
                end
            end
        else
            local enemyDied = type == "UNIT_DIED" and destGUID == enemyGUID
            if (enemyDied) then
                -- Enemy died before it could be found
                ClearEnemyAndEvents()
            end
        end
    elseif (event == "PLAYER_REGEN_DISABLED") then -- Enter combat
        eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
    elseif (event == "PLAYER_REGEN_ENABLED") then -- Out of combat
        ClearEnemyAndEvents()
    elseif (event == "PLAYER_TARGET_CHANGED") then
        if (UnitGUID("target") == enemyGUID) then
            OnBattleStarted:PlayListeners("target")
            ClearEnemyAndEvents()
        end
    end
end);
