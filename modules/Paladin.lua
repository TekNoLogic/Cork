
local myname, Cork = ...
if Cork.MYCLASS ~= "PALADIN" then return end


if Cork.IHASCAT then
	-- Blessing of Might
	local spellname, _, icon = GetSpellInfo(19740)
	Cork:GenerateRaidBuffer(spellname, icon)


	-- Blessing of Kings
	local spellname, _, icon = GetSpellInfo(20217)
	Cork:GenerateRaidBuffer(spellname, icon)


	-- Auras
	Cork:GenerateAdvancedSelfBuffer("Aura", {465, 7294, 19746, 19891, 32223})


	-- Seals
	Cork:GenerateAdvancedSelfBuffer("Seal", {20154, 20165, 31801, 20164})
else
	-- Auras
	Cork:GenerateAdvancedSelfBuffer("Aura", {465, 7294, 19746, 19876, 19888, 19891, 32223})


	-- Seals
	local isawhorde = UnitFactionGroup("player") == "Horde"
	Cork:GenerateAdvancedSelfBuffer("Seal", {21084, 20375, isawhorde and 31892 or 53720, 20166, isawhorde and 53736 or 31801, 20165, 20164})
end


-- Righteous Fury
local spellname, _, icon = GetSpellInfo(25780)
Cork:GenerateSelfBuffer(spellname, icon)
