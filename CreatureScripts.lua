local L = VoiceLinesDatabase
CreatureScripts={}

function CreatureScripts.BlackrockGrunt(unitId)
    if UnitSex(unitId) ~= EnumSex.Male then return {} end
    return { L.blackrock_warcry, L.gruntwarcry1, L.gruntattack1, L.gruntattack3}
end
function CreatureScripts.ScarletCrusade(unitId)
    if UnitSex(unitId) ~= EnumSex.Male then return {} end
    local l = {L.garithosready1, L.garithosyesattack1, L.garithosyesattack2}
    local _, _, raceID = UnitRace("player");
    if raceID ~= EnumRacesIDs.Human then
        table.insert(l, L.garithosyesattack3)
    end
    if raceID == EnumRacesIDs.NightElf then
        table.insert(l, L.garithospissed5)
    end
    return l
end
function CreatureScripts.Defias(unitId)
    if UnitSex(unitId) ~= EnumSex.Male then return {} end
    return {L.banditpissed1, L.bandityesattack2}
end
function CreatureScripts.ForestTroll(unitId)
    if UnitSex(unitId) ~= EnumSex.Male then return {} end
    local l = {L.foresttrollwarcry1, L.foresttrollyesattack1, L.foresttrollyesattack3}
    if raceID == EnumRacesIDs.Human or raceID == EnumRacesIDs.Dwarf or raceID == EnumRacesIDs.Gnome then
        table.insert(l, L.headhunterready1) -- Vengeance for Zul'jin only if player in WC2 Alliance races
    end
end
function CreatureScripts.Headhunter(unitId)
    if UnitSex(unitId) ~= EnumSex.Male then return {} end
    return {L.headhunteryesattack1, L.headhunteryesattack2, L.headhunteryesattack3}
end
function CreatureScripts.IceTroll(unitId)
    if UnitSex(unitId) ~= EnumSex.Male then return {} end
    return {L.icetrollwarcry1, L.icetrollyes4, L.icetrollyes5, L.icetrollyesattack1}
end
function CreatureScripts.ShadowHunter(unitId)
    if UnitSex(unitId) ~= EnumSex.Male then return {} end
    return {L.shadowhunteryesattack1, L.shadowhunteryesattack2, L.shadowhunteryesattack3, L.shadowhunteryesattack4}
end
function CreatureScripts.Rokhan(unitId)
    if UnitSex(unitId) ~= EnumSex.Male then return {} end
    local l = {L.rokhanwarcry1, L.rokhanyesattack3, L.rokhanyesattack4}
    local englishFaction, _ = UnitFactionGroup(unitId)
    if englishFaction == "Horde" then -- Assumed to be Darkspear Troll
        table.insert(l, L.rokhanyesattack2)
    end

    return l
end

