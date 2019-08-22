local folderName, L = ...

print(folderName)
FlavorDisplay = {}
local ConsoleCommands = {}

local function LaunchCommand(msg)
    local args = { string.split(' ', msg) }
    local token = args[1]:lower()
    local cmd = FlavorDisplay:GetCommand(token)
    if (cmd == nil) then
        -- TODO Localize
        print(string.format("|c00FFFF00Error: %s is not a valid FlavorDisplay command.|r", token))
    else
        cmd(args)
    end
end

function FlavorDisplay:AddCommand(token, func)
    ConsoleCommands[token] = func
end

function FlavorDisplay:GetCommand(token)
    return ConsoleCommands[token]
end

SLASH_FLAVORDISPLAY1, SLASH_FLAVORDISPLAY2 = '/flavordisplay', '/fdisplay'

SlashCmdList["FLAVORDISPLAY"] = LaunchCommand

FlavorDisplay:AddCommand("test", function()
    FlavorHeadData:SetCurrentLineInfo(0, "Placeholder", "Text", true, 0)
    FlavorHeadData:SetCurrentLineAnimationInfo(0, 0, 60, nil)
    print("Displaying test frame!")
    FlavorHeadFrame_PrepareModel("target")
    FlavorHeadFrame_PlayCurrent()
end)

function FlavorDisplay:PlayVoiceOver(vo)
    local PlaySoundFunction
    if (type(vo) == "number") then
        PlaySoundFunction = PlaySound
    elseif (type(vo) == "string") then
        PlaySoundFunction = PlaySoundFile
    end
    return PlaySoundFunction(vo, "Talking Head", true, true);
end

function FlavorDisplay:PrintCreatureMessage(message)
    local info = ChatTypeInfo["MONSTER_SAY"];
    -- TODO Custom Color to distinguish from Blizzard messages
    -- Note: Color is in percentages, not integers
    DEFAULT_CHAT_FRAME:AddMessage(message, info.r, info.g, info.b, info.id);
end
