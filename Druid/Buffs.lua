
local _, c = UnitClass("player")
if c ~= "DRUID" then return end


CorkFu_MotW = CorkFu_BuffTemplate:New({
	name = "CorkFu_MotW",

	loc = {
		buff = "Mark of the Wild",
		multibuff = "Gift of the Wild",
		spell = "Mark of the Wild",
		multispell = "Gift of the Wild",
	},
	k = {
		icon = "Spell_Nature_Regeneration",
		usenormalcasting = true,
		scalerank = true,
		ranklevels = {1,10,20,30,40,50,60},
	},
	tagged = {},
})


CorkFu_Thorns = CorkFu_BuffTemplate:New({
	name = "CorkFu_Thorns",

	loc = {
		buff = "Thorns",
		spell = "Thorns",
	},
	k = {
		icon = "Spell_Nature_Thorns",
		usenormalcasting = true,
		scalerank = true,
		ranklevels = {6,14,24,34,44,54},
	},
	tagged = {},
})


CorkFu_Omen = CorkFu_BuffTemplate:New({
	name = "CorkFu_Omen",

	loc = {
		buff = "Omen of Clarity",
		spell = "Omen of Clarity",
	},
	k = {
		selfonly = true,
		icon = "Spell_Nature_CrystalBall",
		usenormalcasting = true,
	},
	tagged = {},
})
