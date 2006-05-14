
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")
local tektech = TekTechEmbed:GetInstance("1")

local template = {}
CorkFu_BuffTemplate = {}

function CorkFu_BuffTemplate:New(info)
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
	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_LOST")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_GAINED")
	if not self.k.selfonly then seaura:RegisterEvent(self, "SPECIAL_AURA_RAID_ROSTER_UPDATE") end
	if not self.k.selfonly then seaura:RegisterEvent(self, "SPECIAL_AURA_PARTY_MEMBERS_CHANGED") end
	if not self.k.selfonly then seaura:RegisterEvent(self, "SPECIAL_AURA_TARGETCHANGED") end

	self:TestUnit("player")
	if not self.k.selfonly then
		for i=1,GetNumPartyMembers() do self:TestUnit("party"..i) end
		for i=1,GetNumRaidMembers() do self:TestUnit("raid"..i) end
	end

	self:TriggerEvent("CORKFU_UPDATE")
end


function template:Disable()
	seaura:UnregisterAllEvents()
end


----------------------------
--      Cork Methods      --
----------------------------

function template:ItemValid()
	if self.k.spell then return tektech:SpellKnown(self.k.spell) end
	if self.k.spells then
		for i in pairs(self.k.spells) do
			if tektech:SpellKnown(i) then return true end
		end
	end
end


local partyunits = {player = true, party1 = true, party2 = true, party3 = true, party4 = true}
function template:UnitValid(unit)
	return (self.k.selfonly and unit == "player")
	or not self.k.selfonly and (GetNumRaidMembers() == 0 or (not partyunits[unit]))
	and UnitExists(unit) and not UnitIsDeadOrGhost(unit) and UnitIsConnected(unit)
end


function template:PutACorkInIt(unit)
	local spell, rank, retarget = self:GetSpell(unit)

	if UnitExists("target") and UnitIsFriend("player", "target") and not UnitIsUnit("target", unit) then
		TargetUnit(unit)
		retarget = true
	end

	if rank and tektech:SpellRankKnown(spell, rank) then CastSpellByName(string.format("%s(Rank %s)", spell, rank))
	else CastSpellByName(spell) end

	if SpellIsTargeting() then SpellTargetUnit(unit) end
	if SpellIsTargeting() then SpellStopTargeting() end
	if retarget then TargetLastTarget() end
end


------------------------------
--      Event Handlers      --
------------------------------

function template:SPECIAL_UNIT_BUFF_GAINED(unit, buff)
	if (not self.k.spell or buff ~= self.k.spell)
	and (not self.k.spells or not self.k.spells[buff])
	and (not self.k.multispell or buff ~= self.k.multispell) then return end

	self.tagged[unit] = buff
	self:TriggerEvent("CORKFU_UPDATE")
end


function template:SPECIAL_UNIT_BUFF_LOST(unit, buff)
	if (not self.k.spell or buff ~= self.k.spell)
	and (not self.k.spells or not self.k.spells[buff])
	and (not self.k.multispell or buff ~= self.k.multispell) then return end

	if self.tagged[unit] == buff then
		self.tagged[unit] = true
		self:TriggerEvent("CORKFU_UPDATE")
	end
end


function template:SPECIAL_AURA_RAID_ROSTER_UPDATE()
	for i=1,GetNumRaidMembers() do self:TestUnit("raid"..i) end
	self:TriggerEvent("CORKFU_UPDATE")
end


function template:SPECIAL_AURA_PARTY_MEMBERS_CHANGED()
	for i=1,GetNumPartyMembers() do self:TestUnit("party"..i) end
	self:TriggerEvent("CORKFU_UPDATE")
end


function template:SPECIAL_AURA_TARGETCHANGED()
	if not UnitIsFriend("target", "player") then
		self.tagged.target = nil
		self:TriggerEvent("CORKFU_UPDATE")
		return
	end

	local sb = self.k.spell and seaura:UnitHasBuff("target", self.k.spell)
	local mb = self.k.multispell and seaura:UnitHasBuff("target", self.k.multispell)
	if self.k.spells then
		for i in pairs(self.k.spells) do
			if seaura:UnitHasBuff("target", i) then sb = i end
		end
	end
	self.tagged.target = sb or mb or true
	self:TriggerEvent("CORKFU_UPDATE")
end


------------------------------
--      Helper Methods      --
------------------------------

function template:TestUnit(unit)
	if not UnitExists(unit) then return end

	local sb = self.k.spell and seaura:UnitHasBuff(unit, self.k.spell)
	local mb = self.k.multispell and seaura:UnitHasBuff(unit, self.k.multispell)
	if self.k.spells then
		for i in pairs(self.k.spells) do
			if seaura:UnitHasBuff("target", i) then sb = i end
		end
	end
	self.tagged[unit] = sb or mb or true
end


function template:GetSpell(unit)
	if self.k.multispell and IsShiftKeyDown() and tektech:SpellKnown(self.k.multispell) then return self.k.multispell
	elseif self.k.spell then return self.k.spell, self:GetRank(unit)
	elseif self.k.spells then return self.k.defaultspell end
end


function template:GetRank(unit)
	if self.k.ranklevels then
		local plvl, ulvl = UnitLevel("player"), UnitLevel(unit)
		for i,v in ipairs(self.k.ranklevels) do
			local nextr = self.k.ranklevels[i+1]
			if not nextr then return
			elseif (ulvl + 10) < nextr then return i end
		end
	end
end


