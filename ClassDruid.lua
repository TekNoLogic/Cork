
local _, c = UnitClass("player")
if c ~= "DRUID" then return end


CorkFu_Druid_Mark = CorkFu_BuffTemplate:New({
	name = "CorkFu_Druid_Mark",
	nicename = "Mark of the Wild",

	k = {
		spell = "Mark of the Wild",
		multispell = "Gift of the Wild",
		icon = "Spell_Nature_Regeneration",
		ranklevels = {1,10,20,30,40,50,60},
	},
})


CorkFu_Druid_Thorns = CorkFu_BuffTemplate:New({
	name = "CorkFu_Druid_Thorns",
	nicename = "Thorns",

	k = {
		spell = "Thorns",
		icon = "Spell_Nature_Thorns",
		ranklevels = {6,14,24,34,44,54},
	},
})


CorkFu_Druid_Omen = CorkFu_BuffTemplate:New({
	name = "CorkFu_Druid_Omen",
	nicename = "Omen of Clarity",

	k = {
		spell = "Omen of Clarity",
		selfonly = true,
		icon = "Spell_Nature_CrystalBall",
	},
})

CorkFu_Druid_Poison = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Druid_Poison",
	nicename = "Cure Poison",

	k = {
		debufftype = "Poison",
		spell = "Cure Poison",
		betterspell = "Abolish Poison",
		icon = "Spell_Nature_NullifyPoison",
	},
})
