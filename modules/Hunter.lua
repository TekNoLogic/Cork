
local myname, Cork = ...
if Cork.MYCLASS ~= "HUNTER" then return end


-- Exotic Munitions
Cork:GenerateAdvancedSelfBuffer("Exotic Munitions", {162537, 162536, 162539})


-- Lone Wolf
Cork:GenerateAdvancedSelfBuffer("Lone Wolf", {160200, 160199, 160198, 160203, 160206, 160205, 172968, 172967})


-- Trap Launcher
local spellname, _, icon = GetSpellInfo(77769)
Cork:GenerateSelfBuffer(spellname, icon)
