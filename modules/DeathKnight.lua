local myname, Cork = ...
if Cork.MYCLASS ~= "DEATHKNIGHT" then return end

-- Path of Frost
local spellname, _, icon = GetSpellInfo(3714)
Cork:GenerateSelfBuffer(spellname, icon)
