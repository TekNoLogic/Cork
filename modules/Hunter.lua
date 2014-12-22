
local myname, Cork = ...
if Cork.MYCLASS ~= "HUNTER" then return end


-- Aspects
Cork:GenerateAdvancedSelfBuffer("Aspects", {5118, 13159, 61648})


-- Exotic Munitions
Cork:GenerateAdvancedSelfBuffer("Exotic Munitions", {162537, 162536, 162539})


-- Trap Launcher
local spellname, _, icon = GetSpellInfo(77769)
Cork:GenerateSelfBuffer(spellname, icon)
