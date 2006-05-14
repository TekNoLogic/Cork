
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
			["Blessing of Might"]      = {4,12,22,32,42,52,60},
			["Blessing of Freedom"]    = true,
			["Blessing of Kings"]      = true,
			["Blessing of Light"]      = {40,50,60},
			["Blessing of Protection"] = {10,24,38},
			["Blessing of Sacrifice"]  = {46,54},
			["Blessing of Salvation"]  = true,
			["Blessing of Sanctuary"]  = {30,40,50,60},
			["Blessing of Wisdom"]     = {14,24,34,44,54,60},
		},
		multispells = {
			["Blessing of Might"]      = "Greater Blessing of Might",
			["Blessing of Kings"]      = "Greater Blessing of Kings",
			["Blessing of Light"]      = "Greater Blessing of Light",
			["Blessing of Salvation"]  = "Greater Blessing of Salvation",
			["Blessing of Sanctuary"]  = "Greater Blessing of Sanctuary",
			["Blessing of Wisdom"]     = "Greater Blessing of Wisdom",
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

