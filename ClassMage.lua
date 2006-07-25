
local _, c = UnitClass("player")
if c ~= "MAGE" then return end

local B = AceLibrary("Babble-Spell-2.0")


CorkFu_Mage_Intellect = CorkFu_BuffTemplate:New({
	name = "Spell_Holy_MagicalSentry",
	nicename = B"Arcane Intellect",

	k = {
		spell = B"Arcane Intellect",
		multispell = B"Arcane Brilliance",
		ranklevels = {1,14,28,42,56},
	},
})


CorkFu_Mage_ManaShield = CorkFu_BuffTemplate:New({
	name = "CorkFu_Mage_ManaShield",
	nicename = B"Mana Shield",

	k = {
		spell = B"Mana Shield",
		selfonly = true,
	},
})


CorkFu_Mage_IceArmor = CorkFu_BuffTemplate:New({
	name = "CorkFu_Mage_IceArmor",
	nicename = "Armor",

	k = {
		spells = {
			[B"Ice Armor"]   = true,
			[B"Frost Armor"] = true,
			[B"Mage Armor"]  = true,
		},
		defaultspell = B"Frost Armor",
		selfonly = true,
	},
})


CorkFu_Mage_DampenMagic = CorkFu_BuffTemplate:New({
	name = "CorkFu_Mage_DampenMagic",
	nicename = "Amplify/Dampen Magic",

	k = {
		spells = {
			[B"Amplify Magic"] = {18,30,42,54},
			[B"Dampen Magic"] = {12,24,36,48,60},
		},
		defaultspell = B"Dampen Magic",
	},
})


CorkFu_Mage_Curse = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Mage_Curse",
	nicename = B"Remove Lesser Curse",

	k = {
		debufftype = "Curse",
		spell = B"Remove Lesser Curse",
	},
})
