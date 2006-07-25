
local _, c = UnitClass("player")
if c ~= "HUNTER" then return end

local B = AceLibrary("Babble-Spell-2.0")


CorkFu_Hunter_True = CorkFu_BuffTemplate:New({
	name = "CorkFu_Hunter_True",
	nicename = B"Trueshot Aura",

	k = {
		spell = B"Trueshot Aura",
		selfonly = true,
	},
})


CorkFu_Hunter_Hawk = CorkFu_BuffTemplate:New({
	name = "CorkFu_Hunter_Hawk",
	nicename = B"Aspects",

	k = {
		spells = {
			[B"Aspect of the Hawk"]    = true,
			[B"Aspect of the Beast"]   = true,
			[B"Aspect of the Monkey"]  = true,
			[B"Aspect of the Cheetah"] = true,
			[B"Aspect of the Pack"]    = true,
			[B"Aspect of the Wild"]    = true,
		},
		defaultspell = B"Aspect of the Hawk",
		selfonly = true,
	},
})

