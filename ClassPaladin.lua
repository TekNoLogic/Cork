
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end

local B = AceLibrary("Babble-Spell-2.2")
local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


i = core:NewModule("Auras", buffs)
i.target = "Self"
i.canstack = true
i.defaultspell = B["Devotion Aura"]
i.spells = {
	[B["Concentration Aura"]]     = true,
	[B["Devotion Aura"]]          = true,
	[B["Fire Resistance Aura"]]   = true,
	[B["Frost Resistance Aura"]]  = true,
	[B["Retribution Aura"]]       = true,
	[B["Shadow Resistance Aura"]] = true,
	[B["Sanctity Aura"]]          = true,
}


i = core:NewModule("Blessings", buffs)
i.target = "Friendly"
i.canstack = true
i.defaultspell = B["Blessing of Might"]
i.spells = {
	[B["Blessing of Might"]]      = true,
	[B["Blessing of Freedom"]]    = true,
	[B["Blessing of Kings"]]      = true,
	[B["Blessing of Light"]]      = true,
	[B["Blessing of Protection"]] = true,
	[B["Blessing of Sacrifice"]]  = true,
	[B["Blessing of Salvation"]]  = true,
	[B["Blessing of Sanctuary"]]  = true,
	[B["Blessing of Wisdom"]]     = true,
}
i.multispells = {
	[B["Blessing of Might"]]      = B["Greater Blessing of Might"],
	[B["Blessing of Kings"]]      = B["Greater Blessing of Kings"],
	[B["Blessing of Light"]]      = B["Greater Blessing of Light"],
	[B["Blessing of Salvation"]]  = B["Greater Blessing of Salvation"],
	[B["Blessing of Sanctuary"]]  = B["Greater Blessing of Sanctuary"],
	[B["Blessing of Wisdom"]]     = B["Greater Blessing of Wisdom"],
}


i = core:NewModule(B["Righteous Fury"], buffs)
i.target = "Self"
i.defaultspell = B["Righteous Fury"]
i.spell = B["Righteous Fury"]
