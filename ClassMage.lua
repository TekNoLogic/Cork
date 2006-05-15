
local _, c = UnitClass("player")
if c ~= "MAGE" then return end


CorkFu_Mage_Intellect = CorkFu_BuffTemplate:New({
	name = "Spell_Holy_MagicalSentry",
	nicename = "Arcane Intellect",

	k = {
		spell = "Arcane Intellect",
		multispell = "Arcane Brilliance",
		icon = "Spell_Holy_MagicalSentry",
		ranklevels = {1,14,28,42,56},
	},
})


CorkFu_Mage_ManaShield = CorkFu_BuffTemplate:New({
	name = "CorkFu_Mage_ManaShield",
	nicename = "Mana Shield",

	k = {
		spell = "Mana Shield",
		icon = "Spell_Shadow_DetectLesserInvisibility",
		selfonly = true,
	},
})


CorkFu_Mage_IceArmor = CorkFu_BuffTemplate:New({
	name = "CorkFu_Mage_IceArmor",
	nicename = "Armor",

	k = {
		spells = {
			["Ice Armor"]   = true,
			["Frost Armor"] = true,
			["Mage Armor"]  = true,
		},
		icons = {
			["Ice Armor"]   = "Spell_Frost_FrostArmor02",
			["Frost Armor"] = "Spell_Frost_FrostArmor02",
			["Mage Armor"]  = "Spell_MageArmor",
		},
		defaultspell = "Frost Armor",
		selfonly = true,
		icon = "Spell_Frost_FrostArmor02",
	},
})


CorkFu_Mage_DampenMagic = CorkFu_BuffTemplate:New({
	name = "CorkFu_Mage_DampenMagic",
	nicename = "Amplify/Dampen Magic",

	k = {
		spells = {
			["Amplify Magic"] = {18,30,42,54},
			["Dampen Magic"] = {12,24,36,48,60},
		},
		defaultspell = "Dampen Magic",
		icon = "Spell_Nature_AbolishMagic",
		icons = {
			["Dampen Magic"]  = "Spell_Nature_AbolishMagic",
			["Amplify Magic"] = "Spell_Holy_FlashHeal",
		},
	},
})


CorkFu_Mage_Curse = CorkFu_DebuffTemplate:New({
	name = "CorkFu_Mage_Curse",
	nicename = "Remove Lesser Curse",

	k = {
		debufftype = "Curse",
		spell = "Remove Lesser Curse",
		icon = "Spell_Nature_RemoveCurse",
	},
})
