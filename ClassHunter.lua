
local _, c = UnitClass("player")
if c ~= "HUNTER" then return end

CorkFu_Huntert_True = CorkFu_BuffTemplate:New({
	name = "CorkFu_Huntert_True",

	k = {
		spell = "Trueshot Aura",
		selfonly = true,
		icon = "Ability_Trueshot",
	},
})


CorkFu_Huntert_Hawk = CorkFu_BuffTemplate:New({
	name = "CorkFu_Huntert_Hawk",

	k = {
		spells = {
			["Aspect of the Hawk"] = true,
			["Aspect of the Beast"] = true,
			["Aspect of the Monkey"] = true,
			["Aspect of the Cheetah"] = true,
			["Aspect of the Pack"] = true,
			["Aspect of the Wild"] = true,
		},
		defaultspell = "Aspect of the Hawk",
		selfonly = true,
		icon = "Ability_Physical_Taunt",
	},
})


