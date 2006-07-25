
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end

local B = AceLibrary("Babble-Spell-2.0")


CorkFu_Priest_PWFort = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_PWFort",
	nicename = B"Power Word: Fortitude",

	k = {
		spell = B"Power Word: Fortitude",
		multispell = B"Prayer of Fortitude",
		ranklevels = {1,12,24,36,48,60},
	},
})


CorkFu_Priest_TouchofWeak = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_TouchofWeak",
	nicename = B"Touch of Weakness",

	k = {
		spell = B"Touch of Weakness",
		selfonly = true,
	},
})


CorkFu_Priest_Feedback = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_Feedback",
	nicename = B"Feedback",

	k = {
		spell = B"Feedback",
		selfonly = true,
	},
})


CorkFu_Priest_InnerFire = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_InnerFire",
	nicename = B"Inner Fire",

	k = {
		spell = B"Inner Fire",
		selfonly = true,
	},
})


CorkFu_Priest_FearWard = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_FearWard",
	nicename = B"Fear Ward",

	k = {
		spell = B"Fear Ward",
	},
})


CorkFu_Priest_Spirit = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_Spirit",
	nicename = B"Divine Spirit",

	k = {
		spell = B"Divine Spirit",
		multispell = B"Prayer of Spirit",
		ranklevels = {30,40,50,60},
	},
})


CorkFu_Priest_PWShield = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_PWShield",
	nicename = B"Power Word: Shield",

	k = {
		spell = B"Power Word: Shield",
		ranklevels = {6,12,18,24,30,36,42,48,54,60},
	},
})


CorkFu_Priest_ShadProt = CorkFu_BuffTemplate:New({
	name = "CorkFu_Priest_ShadProt",
	nicename = B"Shadow Protection",

	k = {
		spell = B"Shadow Protection",
		multispell = B"Prayer of Shadow Protection",
		ranklevels = {30,42,56},
	},
})


CorkFu_Priest_Disease = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Priest_Disease",
	nicename = "Cure Disease",

	k = {
		debufftype = "Curse",
		spell = B"Cure Disease",
		betterspell = B"Abolish Disease",
		diffcost = true,
	},
})


CorkFu_Priest_Magic = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Priest_Magic",
	nicename = "Dispel Magic",

	k = {
		debufftype = "Curse",
		spell = B"Dispel Magic",
		cantargetenemy = true,
	},
})
