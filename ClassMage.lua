
local _, c = UnitClass("player")
if c ~= "MAGE" then return end

local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


local ai = GetSpellInfo(1459) -- Arcane Intellect
i = core:NewModule(ai, buffs)
i.target = "Friendly"
i.spell = ai
i.multispell = GetSpellInfo(23028) -- Arcane Brilliance


i = core:NewModule("Armor", buffs)
i.target = "Self"
i.defaultspell = GetSpellInfo(168) -- Frost Armor
i.spells = {
	[GetSpellInfo(7302)]  = true, -- Ice Armor
	[i.defaultspell]      = true,
	[GetSpellInfo(6117)]  = true, -- Mage Armor
	[GetSpellInfo(30482)] = true, -- Molten Armor
}


i = core:NewModule("Amplify/Dampen Magic", buffs)
i.target = "Raid"
i.defaultspell = GetSpellInfo(604) -- Dampen Magic
i.spells = {
	[GetSpellInfo(1008)] = true, -- Amplify Magic
	[i.defaultspell] = true,
}
