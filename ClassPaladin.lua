
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end

local B = AceLibrary("Babble-Spell-2.0")


CorkFu_Paladin_Aura = CorkFu_BuffTemplate:New({
	name = "CorkFu_Paladin_Aura",
	nicename = "Auras",

	k = {
		spells = {
			[B"Concentration Aura"]     = true,
			[B"Devotion Aura"]          = true,
			[B"Fire Resistance Aura"]   = true,
			[B"Frost Resistance Aura"]  = true,
			[B"Retribution Aura"]       = true,
			[B"Shadow Resistance Aura"] = true,
			[B"Sanctity Aura"]          = true,
		},
		defaultspell = B"Devotion Aura",
		selfonly = true,
	},
})


CorkFu_Paladin_Blessing = CorkFu_BuffTemplate:New({
	name = "CorkFu_Paladin_Blessing",
	nicename = "Blessings",

	k = {
		spells = {
			[B"Blessing of Might"]      = {4,12,22,32,42,52,60},
			[B"Blessing of Freedom"]    = true,
			[B"Blessing of Kings"]      = true,
			[B"Blessing of Light"]      = {40,50,60},
			[B"Blessing of Protection"] = {10,24,38},
			[B"Blessing of Sacrifice"]  = {46,54},
			[B"Blessing of Salvation"]  = true,
			[B"Blessing of Sanctuary"]  = {30,40,50,60},
			[B"Blessing of Wisdom"]     = {14,24,34,44,54,60},
		},
		multispells = {
			[B"Blessing of Might"]      = B"Greater Blessing of Might",
			[B"Blessing of Kings"]      = B"Greater Blessing of Kings",
			[B"Blessing of Light"]      = B"Greater Blessing of Light",
			[B"Blessing of Salvation"]  = B"Greater Blessing of Salvation",
			[B"Blessing of Sanctuary"]  = B"Greater Blessing of Sanctuary",
			[B"Blessing of Wisdom"]     = B"Greater Blessing of Wisdom",
		},
		defaultspell = B"Blessing of Might",
	},
})


CorkFu_Paladin_Magic = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Paladin_Magic",
	nicename = "Remove Magic",

	k = {
		debufftype = "Magic",
		spell = B"Cleanse",
	},
})


CorkFu_Paladin_Poison = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Paladin_Poison",
	nicename = "Remove Poison",

	k = {
		debufftype = "Poison",
		spell = B"Purify",
		betterspell = B"Cleanse",
	},
})


CorkFu_Paladin_Disease = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Paladin_Disease",
	nicename = "Remove Disease",

	k = {
		debufftype = "Disease",
		spell = B"Purify",
		betterspell = B"Cleanse",
	},
})
