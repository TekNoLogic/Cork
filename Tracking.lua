
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")
local tektech = TekTechEmbed:GetInstance("1")
local tablet = AceLibrary("Tablet-2.0")
local BS = AceLibrary("Babble-Spell-2.0")

local core = FuBar_CorkFu
local defaultspell = BS"Find Herbs"
local icons, spells = {}, {
	[BS["Find Herbs"]]       = "Interface\\Icons\\INV_Misc_Flower_02",
	[BS["Find Minerals"]]    = "Interface\\Icons\\Spell_Nature_Earthquake",
	[BS["Find Treasure"]]    = "Interface\\Icons\\Racial_Dwarf_FindTreasure",
	[BS["Track Beasts"]]     = "Interface\\Icons\\Ability_Tracking",
	[BS["Track Humanoids"]]  = "Interface\\Icons\\Spell_Holy_PrayerOfHealing",
	[BS["Track Hidden"]]     = "Interface\\Icons\\Ability_Stealth",
	[BS["Track Elementals"]] = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",
	[BS["Track Undead"]]     = "Interface\\Icons\\Spell_Shadow_DarkSummoning",
	[BS["Track Demons"]]     = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",
	[BS["Track Giants"]]     = "Interface\\Icons\\Ability_Racial_Avatar",
	[BS["Track Dragonkin"]]  = "Interface\\Icons\\INV_Misc_Head_Dragon_01",
	[BS["Sense Undead"]]     = "Interface\\Icons\\Spell_Holy_SenseUndead",
	[BS["Sense Demons"]]     = "Interface\\Icons\\Spell_Shadow_Metamorphosis",
}
for i,v in pairs(spells) do icons[v] = i end


local track = core:NewModule("Tracking")
track.target = "Self"
track.tagged = {player = true}
track.spells = spells


function track:OnEnable()
	for i in pairs(spells) do if tektech:SpellKnown(i) then defaultspell = i end end

	self:RegisterEvent("CorkFu_Rescan")
	self:RegisterEvent("PLAYER_AURAS_CHANGED")
	self:PLAYER_AURAS_CHANGED()
end


----------------------------
--      Cork Methods      --
----------------------------

function track:ItemValid()
	for i in pairs(spells) do
		if tektech:SpellKnown(i) then return true end
	end
end


function track:UnitValid(unit)
	return unit == "player"
end


function track:GetIcon()
	local filter = self.db.profile["Filter Everyone"]
	return filter and BS:GetSpellIcon(filter) or defaultspell and BS:GetSpellIcon(defaultspell)
end


function track:GetTopItem()
	if not self:ItemValid() or self.tagged.player ~= true or not self:UnitValid("player") or self.db.profile.player == -1 then return end

	local spell = self.db.profile["Filter Everyone"] or defaultspell
	return BS:GetSpellIcon(spell), spell
end


function track:PutACorkInIt()
	CastSpellByName(self.db.profile["Filter Everyone"] or defaultspell)
	return true
end


function track:OnTooltipUpdate()
	if not self:ItemValid() or self.tagged.player ~= true or not self:UnitValid("player") or self.db.profile.player == -1 then return end

	local spell = self.db.profile["Filter Everyone"] or defaultspell
	local cat = tablet:AddCategory("hideBlankLine", true)
	cat:AddLine("text", spell, "hasCheck", true, "checked", true, "checkIcon", BS:GetSpellIcon(spell),
		"func", self.PutACorkInIt, "arg1", self)
end


------------------------------
--      Event Handlers      --
------------------------------


function track:CorkFu_Rescan(spell)
	if spells[spell] or spell == "All" then self:PLAYER_AURAS_CHANGED() end
end


function track:PLAYER_AURAS_CHANGED()
	local x = GetTrackingTexture()
	local tex = x and icons[x]
	if tex == self.tagged.player then return end

	self.tagged.player = tex or true
	self:TriggerEvent("CorkFu_Update")
end


