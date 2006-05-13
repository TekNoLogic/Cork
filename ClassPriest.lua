
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end

CorkFu_PWFort = CorkFu_BuffTemplate:New({
	name          = "CorkFu_PWFort",

	loc = {
		buff = "Power Word: Fortitude",
		multibuff = "Prayer of Fortitude",
		spell = "Power Word: Fortitude",
		multispell = "Prayer of Fortitude",
	},
	k = {
		icon = "Spell_Holy_WordFortitude",
		scalerank = true,
		ranklevels = {1,12,24,36,48,60},
	},
	tagged = {},
})
