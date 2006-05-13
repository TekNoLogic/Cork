
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")

local template = {}
CorkFu_BuffTemplate = {}

function CorkFu_BuffTemplate:New(info)
	local bt = AceAddon:new(info)
	for i,v in pairs(template) do bt[i] = v end
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

	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_LOST")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_GAINED")
	if not self.k.selfonly then seaura:RegisterEvent(self, "SPECIAL_AURA_TARGETCHANGED") end
	self:TriggerEvent("CORKFU_UPDATE")
end


function template:Disable()
	self:UnregisterAllEvents()
end


function template:TestUnit(unit)
	if not UnitExists(unit) then return end
	local sb = seaura:UnitHasBuff(unit, self.loc.buff)
	local mb = self.loc.multibuff and seaura:UnitHasBuff(unit, self.loc.multibuff)
	self.tagged[unit] = sb or mb or true
end


function template:SPECIAL_UNIT_BUFF_GAINED(unit, buff)
	if buff ~= self.loc.buff and (not self.loc.multibuff or buff ~= self.loc.multibuff) then return end

	self.tagged[unit] = buff
	self:TriggerEvent("CORKFU_UPDATE")
end


function template:SPECIAL_UNIT_BUFF_LOST(unit, buff)
	if buff ~= self.loc.buff and (not self.loc.multibuff or buff ~= self.loc.multibuff) then return end

	if self.tagged[unit] == buff then
		self.tagged[unit] = true
		self:TriggerEvent("CORKFU_UPDATE")
	end
end


function template:SPECIAL_AURA_TARGETCHANGED()
	if not UnitIsFriend("target", "player") then
		self.tagged.target = nil
		self:TriggerEvent("CORKFU_UPDATE")
		return
	end

	local sb = seaura:UnitHasBuff("target", self.loc.buff)
	local mb = self.loc.multibuff and seaura:UnitHasBuff("target", self.loc.multibuff)
	self.tagged.target = sb or mb or true
	self:TriggerEvent("CORKFU_UPDATE")
end

