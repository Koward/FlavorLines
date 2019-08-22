import csv
import wave
import contextlib


def get_sound_file_duration(file_path):
    with contextlib.closing(wave.open(file_path, 'r')) as f:
        frames = f.getnframes()
        rate = f.getframerate()
        return frames / float(rate)


with open('VoiceLines.lua', 'w', encoding='UTF-8') as lua_file:
    luaHeader = """-- *** DO NOT EDIT. THIS IS A GENERATED FILE. ***
local folderName, _ = ...
--- Format: L.name = { <Text>, <ID|{Filepath, Duration (seconds)>}}
VoiceLinesDatabase = {}
local L = VoiceLinesDatabase\n"""
    lua_file.write(luaHeader)
    with open('VoiceLines.csv', 'r', encoding='UTF-8-sig', newline='') as csv_file:
        reader = csv.DictReader(csv_file)
        locales = reader.fieldnames[2:]
        for locale in locales:
            lua_file.write('\n')
            lua_file.write('if GetLocale() == "' + locale + '" then\n')
            lua_file.write('\tlocal ADDON_SOUND_FOLDER = "Interface\\\\AddOns\\\\" .. folderName .. "\\\\' + locale + '\\\\Sound\\\\"\n')
            for row in reader:
                name = row['Name']
                text = row[locale]
                id = row['ID']
                if id is not '':
                    luaLine = 'L.' + name + ' = { "' + text + '", ' + id + ' }\n'
                else:
                    filepath = './' + locale + '/Sound/' + name + '.wav'
                    duration = str(get_sound_file_duration(filepath))
                    luaLine = 'L.' + name + ' = { "' + text + '", { ADDON_SOUND_FOLDER .. "' + name + '.wav", ' + duration + ' } }\n'
                lua_file.write('\t' + luaLine)
            lua_file.write('end')
