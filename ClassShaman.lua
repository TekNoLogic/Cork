
local _, c = UnitClass("player")
if c ~= "SHAMAN" then return end


CorkFu_Shaman_LightningShield = CorkFu_BuffTemplate:New({
	name = "CorkFu_Shaman_LightningShield",
	nicename = "Lightning Shield",

	k = {
		spell = "Lightning Shield",
		selfonly = true,
		icon = "Spell_Nature_LightningShield",
	},
})


CorkFu_Shaman_Poison = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Shaman_Poison",
	nicename = "Cure Poison",

	k = {
		debufftype = "Poison",
		spell = "Cure Poison",
		icon = "Spell_Nature_NullifyPoison",
	},
})


CorkFu_Shaman_Disease = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Shaman_Disease",
	nicename = "Cure Disease",

	k = {
		debufftype = "Disease",
		spell = "Cure Disease",
		icon = "Spell_Nature_NullifyDisease",
	},
})
