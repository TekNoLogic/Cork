
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")
local tektech = TekTechEmbed:GetInstance("1")
local core = FuBar_CorkFu

local iconpath = "Interface\\Icons\\"


CorkFu_Tracking = AceAddon:new({
	name = "CorkFu_Tracking",
	nicename = "Tracking",

	k = {
		spells = {
			["Find Herbs"]       = "INV_Misc_Flower_02",
			["Find Minerals"]    = "Spell_Nature_Earthquake",
			["Find Treasure"]    = "Racial_Dwarf_FindTreasure",
			["Track Beasts"]     = "Ability_Tracking",
			["Track Humanoids"]  = "Spell_Holy_PrayerOfHealing",
			["Track Hidden"]     = "Ability_Stealth",
			["Track Elementals"] = "Spell_Frost_SummonWaterElemental",
			["Track Undead"]     = "Spell_Shadow_DarkSummoning",
			["Track Demons"]     = "Spell_Shadow_SummonFelHunter",
			["Track Giants"]     = "Ability_Racial_Avatar",
			["Track Dragonkin"]  = "INV_Misc_Head_Dragon_01",
			["Sense Undead"]     = "Spell_Holy_SenseUndead",
			["Sense Demons"]     = "Spell_Shadow_Metamorphosis",
		},
		icons = {},
		selfonly = true,
		defaultspell = "Find Herbs",
		icon = "INV_Misc_Head_Dragon_01",
	},
	tagged = {player = true},
})


function CorkFu_Tracking:Initialize()
	for i,v in pairs(self.k.spells) do self.k.icons[iconpath..v] = i end
	for i in pairs(self.k.spells) do if tektech:SpellKnown(i) then self.k.defaultspell = i end end
	self:TriggerEvent("CORKFU_REGISTER_MODULE", self)
end


function CorkFu_Tracking:Enable()
	self:RegisterEvent("CORKFU_RESCAN")
	self:RegisterEvent("PLAYER_AURAS_CHANGED")
	self:PLAYER_AURAS_CHANGED()

	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_Tracking:Disable()
	self:UnregisterAllEvents()
end


----------------------------
--      Cork Methods      --
----------------------------

function CorkFu_Tracking:ItemValid()
	for i in pairs(self.k.spells) do
		if tektech:SpellKnown(i) then return true end
	end
end


function CorkFu_Tracking:UnitValid(unit)
	return unit == "player"
end


function CorkFu_Tracking:GetIcon()
	local filter = tektech:TableGetVal(core.data, self.name, "Filters", "Everyone")
	return filter and self.k.spells[filter] or self.k.defaultspell and self.k.spells[self.k.defaultspell] or self.k.icon
end


function CorkFu_Tracking:PutACorkInIt(unit)
	CastSpellByName(tektech:TableGetVal(core.data, self.name, "Filters", "Everyone") or self.k.defaultspell)
end


------------------------------
--      Event Handlers      --
------------------------------


function CorkFu_Tracking:CORKFU_RESCAN(spell)
	if self.k.spells[spell] or spell == "All" then self:PLAYER_AURAS_CHANGED() end
end


function CorkFu_Tracking:PLAYER_AURAS_CHANGED()
	local x = GetTrackingTexture()
	local tex = x and self.k.icons[x]
	if tex == self.tagged.player then return end

	self.tagged.player = tex or true
	self:TriggerEvent("CORKFU_UPDATE")
end


--------------------------------
--      Load this bitch!      --
--------------------------------
CorkFu_Tracking:RegisterForLoad()
