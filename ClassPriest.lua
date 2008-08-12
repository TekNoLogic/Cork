
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end


-- Fort
local multispell, spellname, _, icon = GetSpellInfo(21562), GetSpellInfo(1243)
Cork:GenerateRaidBuffer(spellname, multispell, icon)


-- Inner Fire
local spellname, _, icon = GetSpellInfo(588)
Cork:GenerateSelfBuffer(spellname, icon)
