
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")
local tektech = TekTechEmbed:GetInstance("1")
local babble = BabbleLib:GetInstance("Spell 1.1")
local core = FuBar_CorkFu

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
	self:RegisterEvent("CORKFU_RESCAN")

	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_LOST")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_GAINED")
	if not self.k.selfonly then seaura:RegisterEvent(self, "SPECIAL_AURA_RAID_ROSTER_UPDATE") end
	if not self.k.selfonly then seaura:RegisterEvent(self, "SPECIAL_AURA_PARTY_MEMBERS_CHANGED") end
	if not self.k.selfonly then seaura:RegisterEvent(self, "SPECIAL_AURA_TARGETCHANGED") end

	self:ScanUnits()

	self:TriggerEvent("CORKFU_UPDATE")
end


function template:Disable()
	self:UnregisterAllEvents()
	seaura:UnregisterAllEvents(self)
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


function template:GetIcon(unit)
	local spell = self:GetSpell(unit)
	return spell and babble:GetSpellIcon(spell) or self.k.icon
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


function template:CORKFU_RESCAN(spell)
	if spell == self.k.spell or self.k.spells and self.k.spells[spell] or spell == self.k.multispell or spell == "All" then
		self:ScanUnits()
	end
end


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
	self.tagged.target = nil

	if UnitExists("target") and UnitIsFriend("target", "player") then
		local sb = self.k.spell and seaura:UnitHasBuff("target", self.k.spell)
		local mb = self.k.multispell and seaura:UnitHasBuff("target", self.k.multispell)
		if self.k.spells then
			for i in pairs(self.k.spells) do
				if seaura:UnitHasBuff("target", i) then sb = i end
			end
		end
		self.tagged.target = sb or mb or true
	end

	self:TriggerEvent("CORKFU_UPDATE")
end


------------------------------
--      Helper Methods      --
------------------------------

function template:ScanUnits()
	self:TestUnit("player")
	if not self.k.selfonly then
		for i=1,GetNumPartyMembers() do self:TestUnit("party"..i) end
		for i=1,GetNumRaidMembers() do self:TestUnit("raid"..i) end
	end
end


function template:TestUnit(unit)
	if not UnitExists(unit) then
		self.tagged[unit] = nil
		return
	end

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
	assert(unit, "No unit passed")
	assert(UnitExists(unit), "Unit does not exist")

	if self.k.multispell and IsShiftKeyDown() and tektech:SpellKnown(self.k.multispell) then return self.k.multispell
	elseif self.k.spell then return self.k.spell, self:GetRank(unit)
	elseif self.k.spells then
		if self.k.selfonly then
			return tektech:TableGetVal(core.data, self.name, "Filters", "Everyone") or self.k.defaultspell
		else
			local spell = self:GetSpellFilter(unit)
			if not spell then return end

			local ms = self.k.multispells and self.k.multispells[spell]
			if IsShiftKeyDown() and ms then return ms end

			local rank = self:GetRank(unit, self.k.spells[spell])
			return spell, rank
		end
	end
end


function template:GetSpellFilter(unit)
	assert(unit, "No unit passed")
	assert(UnitExists(unit), "Unit does not exist")
	assert(self.k.defaultspell, "No default spell")

	local def = self.k.defaultspell
	local istarget = unit == "target"
	local ispc = UnitIsPlayer(unit) and not UnitInParty(unit) and not UnitInRaid(unit)

	local pc = istarget and ispc and tektech:TableGetVal(core.data, self.name, "Filters", "Target Player")
	if pc then return pc ~= -1 and pc or def end

	local npc = istarget and not ispc and tektech:TableGetVal(core.data, self.name, "Filters", "Target NPC")
	if npc then return npc ~= -1 and npc or def end

	local byname = tektech:TableGetVal(core.data, self.name, "Filters", "Unit: "..UnitName(unit))
	if byname then return byname ~= -1 and byname or def end

	local _,class = UnitClass(unit)
	local byclass = class and tektech:TableGetVal(core.data, self.name, "Filters", "Class: ".. class)
	if byclass then return byclass ~= -1 and byclass or def end

	local i, g, byparty
	if GetNumRaidMembers() > 0 then _, _, i = string.find(unit, "raid(%d+)") end
	if i then _, _, g = GetRaidRosterInfo(tonumber(i)) end
	if g then byparty = tektech:TableGetVal(core.data, self.name, "Filters", "Party: "..g) end
	if byparty then return byparty ~= -1 and byparty or def end

	local everyone = tektech:TableGetVal(core.data, self.name, "Filters", "Everyone")
	if everyone then return everyone ~= -1 and everyone or def end

	return def
end


function template:GetRank(unit, ranks)
	local ranklevels = type(ranks) == "table" and ranks or self.k.ranklevels
	if ranklevels then
		local plvl, ulvl = UnitLevel("player"), UnitLevel(unit)
		for i,v in ipairs(ranklevels) do
			local nextr = ranklevels[i+1]
			if not nextr then return
			elseif (ulvl + 10) < nextr then return i end
		end
	end
end


