
local myname, Cork = ...
if Cork.MYCLASS ~= "MAGE" then return end


-- Armor
Cork:GenerateAdvancedSelfBuffer("Armor", {168, 7302, 6117, 30482})

-- Fuckus Magic
local spellname, _, icon = GetSpellInfo(54646)
Cork:GenerateLastBuffedBuffer(spellname, icon)
