import csv

with open('CreatureScriptsMappings.lua', 'w', encoding='UTF-8') as lua_file:
    luaHeader = """-- *** DO NOT EDIT. THIS IS A GENERATED FILE. ***
--- Format: M[ID] = { lines=<Scripting function>, chance=<optional int 0-100>, named=<optional bool>}
CreatureScriptsMappings = {}
local M = CreatureScriptsMappings\n"""
    lua_file.write(luaHeader)
    lua_file.write('\n')
    with open('CreatureScriptsMappings.csv', 'r', encoding='UTF-8-sig', newline='') as csv_file:
        reader = csv.DictReader(csv_file)
        for row in reader:
            id = row['ID']
            line = row['OnBattleStarted']
            lua_file.write('M['+id+'] = {lines=CreatureScripts.'+line+'}\n')
