
local _, c = UnitClass("player")
if c ~= "DRUID" then return end

local B = AceLibrary("Babble-Spell-2.0")


CorkFu_Druid_Mark = CorkFu_BuffTemplate:New({
	name = "CorkFu_Druid_Mark",
	nicename = B"Mark of the Wild",

	k = {
		spell = B"Mark of the Wild",
		multispell = B"Gift of the Wild",
		ranklevels = {1,10,20,30,40,50,60},
	},
})


CorkFu_Druid_Thorns = CorkFu_BuffTemplate:New({
	name = "CorkFu_Druid_Thorns",
	nicename = B"Thorns",

	k = {
		spell = B"Thorns",
		ranklevels = {6,14,24,34,44,54},
	},
})


CorkFu_Druid_Omen = CorkFu_BuffTemplate:New({
	name = "CorkFu_Druid_Omen",
	nicename = B"Omen of Clarity",

	k = {
		spell = B"Omen of Clarity",
		selfonly = true,
	},
})


CorkFu_Druid_Poison = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Druid_Poison",
	nicename = B"Cure Poison",

	k = {
		debufftype = "Poison",
		spell = B"Cure Poison",
		betterspell = B"Abolish Poison",
	},
})


CorkFu_Druid_Curse = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Druid_Curse",
	nicename = B"Remove Curse",

	k = {
		debufftype = "Curse",
		spell = B"Remove Curse",
	},
})
