
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end


CorkFu_Paladin_Aura = CorkFu_BuffTemplate:New({
	name = "CorkFu_Paladin_Aura",
	nicename = "Auras",

	k = {
		spells = {
			["Concentration Aura"]     = true,
			["Devotion Aura"]          = true,
			["Fire Resistance Aura"]   = true,
			["Frost Resistance Aura"]  = true,
			["Retribution Aura"]       = true,
			["Shadow Resistance Aura"] = true,
			["Sanctity Aura"]          = true,
		},
		defaultspell = "Devotion Aura",
		selfonly = true,
		icon = "Spell_Holy_DevotionAura",
		icons = {
			["Concentration Aura"]     = "Spell_Holy_MindSooth",
			["Devotion Aura"]          = "Spell_Holy_DevotionAura",
			["Fire Resistance Aura"]   = "Spell_Fire_SealOfFire",
			["Frost Resistance Aura"]  = "Spell_Frost_WizardMark",
			["Retribution Aura"]       = "Spell_Holy_AuraOfLight",
			["Shadow Resistance Aura"] = "Spell_Shadow_SealOfKings",
			["Sanctity Aura"]          = "Spell_Holy_MindVision",
		},
	},
})


CorkFu_Paladin_Blessing = CorkFu_BuffTemplate:New({
	name = "CorkFu_Paladin_Blessing",
	nicename = "Blessings",

	k = {
		spells = {
			["Blessing of Might"]      = true,
			["Blessing of Freedom"]    = true,
			["Blessing of Kings"]      = true,
			["Blessing of Light"]      = true,
			["Blessing of Protection"] = true,
			["Blessing of Sacrifice"]  = true,
			["Blessing of Salvation"]  = true,
			["Blessing of Sanctuary"]  = true,
			["Blessing of Wisdom"]     = true,
		},
		defaultspell = "Blessing of Might",
		icon = "Spell_Holy_SealOfWisdom",
		icons = {
			["Blessing of Might"]      = "Spell_Holy_FistOfJustice",
			["Blessing of Freedom"]    = "Spell_Holy_SealOfValor",
			["Blessing of Kings"]      = "Spell_Magic_MageArmor",
			["Blessing of Light"]      = "Spell_Holy_PrayerOfHealing02",
			["Blessing of Protection"] = "Spell_Holy_SealOfProtection",
			["Blessing of Sacrifice"]  = "Spell_Holy_SealOfSacrifice",
			["Blessing of Salvation"]  = "Spell_Holy_SealOfSalvation",
			["Blessing of Sanctuary"]  = "Spell_Nature_LightningShield",
			["Blessing of Wisdom"]     = "Spell_Holy_SealOfWisdom",
		},
	},
})

