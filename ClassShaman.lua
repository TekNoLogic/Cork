
local _, c = UnitClass("player")
if c ~= "SHAMAN" then return end

local B = AceLibrary("Babble-Spell-2.0")


CorkFu_Shaman_LightningShield = CorkFu_BuffTemplate:New({
	name = "CorkFu_Shaman_LightningShield",
	nicename = B"Lightning Shield",

	k = {
		spell = B"Lightning Shield",
		selfonly = true,
	},
})


CorkFu_Shaman_Poison = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Shaman_Poison",
	nicename = B"Cure Poison",

	k = {
		debufftype = "Poison",
		spell = B"Cure Poison",
	},
})


CorkFu_Shaman_Disease = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Shaman_Disease",
	nicename = B"Cure Disease",

	k = {
		debufftype = "Disease",
		spell = B"Cure Disease",
	},
})
