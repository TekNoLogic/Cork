
local myname, Cork = ...
if Cork.MYCLASS ~= "MAGE" then return end


-- Armor
Cork:GenerateAdvancedSelfBuffer("Armor", {30482, 7302, 6117})


-- Fuckus Magic
local spellname, _, icon = GetSpellInfo(54646)
Cork:GenerateLastBuffedBuffer(spellname, icon)


-- Arcane Briliance
local altspellname, spellname, _, icon = GetSpellInfo(61316), GetSpellInfo(1459)
Cork:GenerateRaidBuffer(spellname, icon, altspellname, true)
