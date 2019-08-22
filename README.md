# FlavorLines
** Adds voiced lines to creatures. Useless, thus necessary. **

## AddOn is in deep WIP state
Don't hesitate to make suggestions!
The number of creatures with voice lines is currently limited. 

If you want to test the AddOn, I suggest the Frostmane Trolls in Dun Morogh or the (living) Scarlet Crusaders in Tirisfal.
The list of creatures handled is in CreatureMappings.csv

## Information
- Most voicelines come from Warcraft 3
- Only enUS localization at the moment, though more could be added in the future
- At the moment testing is done on Retail and I am waiting for Classic release to ensure everything works properly.
- Classic is the end target. Retail creatures usually already have lines added by Blizzard, making this AddOn less relevant. 
- The lines are added progressively, beginning with starting zones and most common mobs.
## Configuration
The AddOn can be configured through the in-game panel Interface>AddOns>FlavorLine.

At the moment, the following options are proposed:
- Enable/disable the sound
- Display/do not display the line in the chat (like a "say" message)
- Display/do not display a talking head frame

## Building process
This AddOn uses CSV tables converted to Lua with Python scripts.
It was a necessary step because the scripts also pre-computes some values like line durations.

### VoiceLines
This table holds all voicelines. 
Each line has a name, optionally an ID when its already in the WoW client, and an enUS text.
When the audio is not in the client, it must be supplied in a .wav file with the same name as the line inside enUS/Sound/.

### CreatureMappings
Contains the mappings between a creature, symbolized by its ID&name, and a function that will retrieve the voice lines.
The functions must be written in CreatureScripts.lua. This allows to display lines based on, for example, the race of the player.