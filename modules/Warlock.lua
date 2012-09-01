
local myname, Cork = ...
if Cork.MYCLASS ~= "WARLOCK" then return end

-- Grimoire of Sacrifice
local spellname, _, icon = GetSpellInfo(108503)
Cork:GenerateSelfBuffer(spellname, icon)
