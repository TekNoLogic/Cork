
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end


-- Righteous Fury
local spellname, _, icon = GetSpellInfo(25780)
Cork:GenerateSelfBuffer(spellname, icon)


-- Auras
Cork:GenerateAdvancedSelfBuffer("Aura", {465, 7294, 19746, 19876, 19888, 19891, 32223})

-- Seals
local isawhorde = UnitFactionGroup("player") == "Horde"
Cork:GenerateAdvancedSelfBuffer("Seal", {21084, 20375, isawhorde and 31892 or 53720, 20166, isawhorde and 53736 or 31801, 20165, 20164})
