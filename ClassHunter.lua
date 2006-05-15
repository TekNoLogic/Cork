
local _, c = UnitClass("player")
if c ~= "HUNTER" then return end

CorkFu_Hunter_True = CorkFu_BuffTemplate:New({
	name = "CorkFu_Hunter_True",
	nicename = "Trueshot Aura",

	k = {
		spell = "Trueshot Aura",
		selfonly = true,
		icon = "Ability_Trueshot",
	},
})


CorkFu_Hunter_Hawk = CorkFu_BuffTemplate:New({
	name = "CorkFu_Hunter_Hawk",
	nicename = "Aspects",

	k = {
		spells = {
			["Aspect of the Hawk"]    = true,
			["Aspect of the Beast"]   = true,
			["Aspect of the Monkey"]  = true,
			["Aspect of the Cheetah"] = true,
			["Aspect of the Pack"]    = true,
			["Aspect of the Wild"]    = true,
		},
		icons = {
			["Aspect of the Hawk"]    = "Spell_Nature_RavenForm",
			["Aspect of the Beast"]   = "Ability_Mount_PinkTiger",
			["Aspect of the Monkey"]  = "Ability_Hunter_AspectOfTheMonkey",
			["Aspect of the Cheetah"] = "Ability_Mount_JungleTiger",
			["Aspect of the Pack"]    = "Ability_Mount_WhiteTiger",
			["Aspect of the Wild"]    = "Spell_Nature_ProtectionformNature",
		},
		defaultspell = "Aspect of the Hawk",
		selfonly = true,
		icon = "Ability_Physical_Taunt",
	},
})

