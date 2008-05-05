
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end

local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


i = core:NewModule("Auras", buffs)
i.target = "Self"
i.canstack = true
i.defaultspell = GetSpellInfo(465) -- Devotion Aura
i.spells = {
	[GetSpellInfo(19746)] = true, -- Concentration Aura
	[i.defaultspell]      = true, -- Devotion Aura
	[GetSpellInfo(19891)] = true, -- Fire Resistance Aura
	[GetSpellInfo(19888)] = true, -- Frost Resistance Aura
	[GetSpellInfo(7294)]  = true, -- Retribution Aura
	[GetSpellInfo(19876)] = true, -- Shadow Resistance Aura
	[GetSpellInfo(20218)] = true, -- Sanctity Aura
}


i = core:NewModule("Blessings", buffs)
i.target = "Friendly"
i.canstack = true
i.defaultspell = GetSpellInfo(19740)
i.spells = {
	[i.defaultspell]      = true, -- Blessing of Might
	[GetSpellInfo(1044)]  = true, -- Blessing of Freedom
	[GetSpellInfo(20217)] = true, -- Blessing of Kings
	[GetSpellInfo(19977)] = true, -- Blessing of Light
	[GetSpellInfo(1022)]  = true, -- Blessing of Protection
	[GetSpellInfo(6940)]  = true, -- Blessing of Sacrifice
	[GetSpellInfo(1038)]  = true, -- Blessing of Salvation
	[GetSpellInfo(20911)] = true, -- Blessing of Sanctuary
	[GetSpellInfo(19742)] = true, -- Blessing of Wisdom
}
i.multispells = {
	[GetSpellInfo(25782)] = true, -- Greater Blessing of Might
	[GetSpellInfo(25898)] = true, -- Greater Blessing of Kings
	[GetSpellInfo(25890)] = true, -- Greater Blessing of Light
	[GetSpellInfo(25895)] = true, -- Greater Blessing of Salvation
	[GetSpellInfo(25899)] = true, -- Greater Blessing of Sanctuary
	[GetSpellInfo(25894)] = true, -- Greater Blessing of Wisdom
}


local rf = GetSpellInfo(25780) -- Righteous Fury
i = core:NewModule(rf, buffs)
i.target = "Self"
i.defaultspell = rf
i.spell = rf
