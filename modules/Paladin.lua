
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end


-- Righteous Fury
local spellname, _, icon = GetSpellInfo(25780)
Cork:GenerateSelfBuffer(spellname, icon)


-- Auras
Cork:GenerateAdvancedSelfBuffer("Aura", {465, 7294, 19746, 19876, 19888, 19891, 32223})
