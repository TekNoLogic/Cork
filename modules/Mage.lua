
local _, c = UnitClass("player")
if c ~= "MAGE" then return end


-- Armor
Cork:GenerateAdvancedSelfBuffer("Armor", {168, 7302, 6117, 30482})


--~ i = core:NewModule("Amplify/Dampen Magic", buffs)
--~ i.target = "Raid"
--~ i.defaultspell = GetSpellInfo(604) -- Dampen Magic
--~ i.spells = {
--~ 	[GetSpellInfo(1008)] = true, -- Amplify Magic
--~ 	[i.defaultspell] = true,
--~ }
