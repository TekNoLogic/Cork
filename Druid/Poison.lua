
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end

local seaura = SpecialEventsEmbed:GetInstance("Aura 1")

CorkFu_AbolishPoison = AceAddon:new({
	name          = "CorkFu_AbolishPoison",
	cmd           = AceChatCmd:new({}, {}),

	loc = {
		debufftype = "Poison",
		spell = "Abolish Poison",
	},
	k = {
		icon = "Spell_Nature_NullifyPoison",
		usenormalcasting = true,
	},
	tagged = {},
})


function CorkFu_AbolishPoison:Initialize()
	self:TriggerEvent("CORKFU_REGISTER_MODULE", self)
end


function CorkFu_AbolishPoison:Enable()
	self:TestUnit("player")
	for i=1,GetNumPartyMembers() do self:TestUnit("party"..i) end
	for i=1,GetNumRaidMembers() do self:TestUnit("raid"..i) end

	seaura:RegisterEvent(self, "SPECIAL_UNIT_DEBUFF_GAINED")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_DEBUFF_LOST")
	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_AbolishPoison:Disable()
	self:UnregisterAllEvents()
end


function CorkFu_AbolishPoison:TestUnit(unit)
	if not UnitExists(unit) then return end
	self.tagged[unit] = seaura:UnitHasDebuffType(unit, self.loc.debufftype) and true
end


function CorkFu_AbolishPoison:SPECIAL_UNIT_DEBUFF_LOST(unit, debuff, apps, dbtype)
	if dbtype ~= self.loc.debufftype then return end

	self.tagged[unit] = nil
	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_AbolishPoison:SPECIAL_UNIT_DEBUFF_GAINED(unit, debuff, apps, dbtype)
	if dbtype ~= self.loc.debufftype then return end

	self.tagged[unit] = true
	self:TriggerEvent("CORKFU_UPDATE")
end


--------------------------------
--      Load this bitch!      --
--------------------------------
CorkFu_AbolishPoison:RegisterForLoad()
