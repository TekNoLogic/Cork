
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")
local tektech = TekTechEmbed:GetInstance("1")

local template = {}
CorkFu_DebuffTemplate = {}

function CorkFu_DebuffTemplate:New(info)
	local bt = AceAddon:new(info)
	for i,v in pairs(template) do bt[i] = v end
	bt.tagged = {}
	bt:RegisterForLoad()
	return bt
end


function template:Initialize()
	self:TriggerEvent("CORKFU_REGISTER_MODULE", self)
end


function template:Enable()
	self:TestUnit("player")
	if not self.k.selfonly then
		for i=1,GetNumPartyMembers() do self:TestUnit("party"..i) end
		for i=1,GetNumRaidMembers() do self:TestUnit("raid"..i) end
	end

	seaura:RegisterEvent(self, "SPECIAL_UNIT_DEBUFF_GAINED")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_DEBUFF_LOST")
	if not self.k.selfonly then seaura:RegisterEvent(self, "SPECIAL_AURA_TARGETCHANGED") end
	self:TriggerEvent("CORKFU_UPDATE")
end


function template:Disable()
	seaura:UnregisterAllEvents()
end


----------------------------
--      Cork Methods      --
----------------------------

function template:ItemValid()
	return tektech:SpellKnown(self.loc.spell)
end


function template:PutACorkInIt(unit)
	local retarget

	if UnitExists("target") and UnitIsFriend("player", "target") and not UnitIsUnit("target", unit) then
		TargetUnit(unit)
		retarget = true
	end
	print(self.loc.betterspell and tektech:SpellKnown(self.loc.betterspell) or self.loc.spell)
	CastSpellByName(self.loc.betterspell and tektech:SpellKnown(self.loc.betterspell) and self.loc.betterspell or self.loc.spell)

	if SpellIsTargeting() then SpellTargetUnit(unit) end
	if SpellIsTargeting() then SpellStopTargeting() end
	if retarget then TargetLastTarget() end
end


------------------------------
--      Event Handlers      --
------------------------------

function template:SPECIAL_UNIT_DEBUFF_LOST(unit, debuff, apps, dbtype)
	if dbtype ~= self.loc.debufftype then return end

	self.tagged[unit] = nil
	self:TriggerEvent("CORKFU_UPDATE")
end


function template:SPECIAL_UNIT_DEBUFF_GAINED(unit, debuff, apps, dbtype)
	if dbtype ~= self.loc.debufftype then return end

	self.tagged[unit] = true
	self:TriggerEvent("CORKFU_UPDATE")
end


function template:SPECIAL_AURA_TARGETCHANGED()
	if not UnitIsFriend("target", "player") then
		self.tagged.target = nil
		self:TriggerEvent("CORKFU_UPDATE")
		return
	end

	self.tagged.target = seaura:UnitHasDebuffType("target", self.loc.debufftype) and true
	self:TriggerEvent("CORKFU_UPDATE")
end


------------------------------
--      Helper Methods      --
------------------------------

function template:TestUnit(unit)
	if not UnitExists(unit) then return end
	self.tagged[unit] = seaura:UnitHasDebuffType(unit, self.loc.debufftype) and true
end


