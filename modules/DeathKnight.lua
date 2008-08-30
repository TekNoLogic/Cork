
local _, c = UnitClass("player")
if c ~= "DEATHKNIGHT" then return end


-- Bone Shield
local spellname, _, icon = GetSpellInfo(49222)
Cork:GenerateSelfBuffer(spellname, icon)


-- Path of Frost
local spellname, _, icon = GetSpellInfo(3714)
Cork:GenerateSelfBuffer(spellname, icon)


-- Horn of Winter
local spellname, _, icon = GetSpellInfo(57330)
Cork:GenerateSelfBuffer(spellname, icon)
