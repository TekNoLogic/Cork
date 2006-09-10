
local AceOO = AceLibrary("AceOO-2.0")
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")
local tektech = TekTechEmbed:GetInstance("1")
local tablet = AceLibrary("Tablet-2.0")
local BS = AceLibrary("Babble-Spell-2.0")
local BC = BabbleLib:GetInstance("Class 1.1")
local core = FuBar_CorkFu

local raidunitnum, partyids = {}, {player = "Self", pet = "Pet"}
for i=1,40 do raidunitnum["raid"..i] = i end
for i=1,4 do
	partyids["party"..i] = "Party"
	partyids["party"..i.."pet"] = "Party Pet"
end


local template = AceOO.Mixin {
	"OnEnable",
	"OnDisable",
	"ItemValid",
	"UnitValid",
	"GetIcon",
	"PutACorkInIt",
	"SPECIAL_UNIT_DEBUFF_LOST",
	"SPECIAL_UNIT_DEBUFF_GAINED",
	"SPECIAL_AURA_RAID_ROSTER_UPDATE",
	"SPECIAL_AURA_PARTY_MEMBERS_CHANGED",
	"SPECIAL_AURA_TARGETCHANGED",
	"TestUnit",
	"GetSpell",
	"OnTooltipUpdate",
	"GetTopItem",
}
core:RegisterTemplate("Debuffs", template)


function template:OnEnable()
	if not self.tagged the self.tagged = {} end

	self:TestUnit("player")
	if self.target ~= "Self" then
		for i=1,GetNumPartyMembers() do self:TestUnit("party"..i) end
		for i=1,GetNumRaidMembers() do self:TestUnit("raid"..i) end
	end

	seaura:RegisterEvent(self, "SPECIAL_UNIT_DEBUFF_GAINED")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_DEBUFF_LOST")
	if self.target ~= "Self" then seaura:RegisterEvent(self, "SPECIAL_AURA_RAID_ROSTER_UPDATE") end
	if self.target ~= "Self" then seaura:RegisterEvent(self, "SPECIAL_AURA_PARTY_MEMBERS_CHANGED") end
	if self.target ~= "Self" then seaura:RegisterEvent(self, "SPECIAL_AURA_TARGETCHANGED") end
	self:TriggerEvent("CorkFu_Update")
end


function template:OnDisable()
	seaura:UnregisterAllEvents()
end


----------------------------
--      Cork Methods      --
----------------------------

function template:ItemValid()
	return tektech:SpellKnown(self.spell)
end


local partyunits = {player = true, party1 = true, party2 = true, party3 = true, party4 = true}
function template:UnitValid(unit)
	return (GetNumRaidMembers() == 0 or not partyunits[unit]) and UnitExists(unit)
end


function template:GetIcon(unit)
	return BS:GetSpellIcon(self:GetSpell(unit))
end


function template:PutACorkInIt(unit)
	if not unit then
		local _,_,unit = self:GetTopItem()
		if unit then return self:PutACorkInIt(unit) end
		return
	end
	local retarget

	if UnitExists("target") and (UnitIsFriend("player", "target") or self.cantargetenemy) and not UnitIsUnit("target", unit) then
		TargetUnit(unit)
		retarget = true
	end
	CastSpellByName(self:GetSpell(unit))

	if SpellIsTargeting() then SpellTargetUnit(unit) end
	if SpellIsTargeting() then SpellStopTargeting() end
	if retarget then TargetLastTarget() end
end


function template:GetTopItem()
	if not self:ItemValid() then return end

	for unit,val in pairs(self.tagged) do
		if val == true and self:UnitValid(unit) and not core:UnitIsFiltered(self, unit) then
			local color = (UnitInParty(unit) or UnitInRaid(unit)) and string.format("|cff%s", BC:GetHexColor(UnitClass(unit))) or "|cff00ff00"
			return self:GetIcon(unit), color.. UnitName(unit), unit
		end
	end
end

------------------------------
--      Event Handlers      --
------------------------------

function template:SPECIAL_UNIT_DEBUFF_LOST(unit, debuff, apps, dbtype)
	if unit == "mouseover" or dbtype ~= self.debufftype then return end

	self.tagged[unit] = nil
	self:TriggerEvent("CorkFu_Update")
end


function template:SPECIAL_UNIT_DEBUFF_GAINED(unit, debuff, apps, dbtype)
	if unit == "mouseover" or dbtype ~= self.debufftype then return end

	self.tagged[unit] = true
	self:TriggerEvent("CorkFu_Update")
end


function template:SPECIAL_AURA_RAID_ROSTER_UPDATE()
	for i=1,GetNumRaidMembers() do self:TestUnit("raid"..i) end
	self:TriggerEvent("CorkFu_Update")
end


function template:SPECIAL_AURA_PARTY_MEMBERS_CHANGED()
	for i=1,GetNumPartyMembers() do self:TestUnit("party"..i) end
	self:TriggerEvent("CorkFu_Update")
end


function template:SPECIAL_AURA_TARGETCHANGED()
	if not UnitIsFriend("target", "player") then
		self.tagged.target = nil
		self:TriggerEvent("CorkFu_Update")
		return
	end

	self.tagged.target = seaura:UnitHasDebuffType("target", self.debufftype) and true
	self:TriggerEvent("CorkFu_Update")
end


------------------------------
--      Helper Methods      --
------------------------------

function template:TestUnit(unit)
	if not UnitExists(unit) then return end
	self.tagged[unit] = seaura:UnitHasDebuffType(unit, self.debufftype) and true
end


function template:GetSpell(unit)
	if self.betterspell and tektech:SpellKnown(self.betterspell)
	and (self.diffcost and IsShiftKeyDown() or not self.diffcost) then
		return self.betterspell
	end

	return self.spell
end


function template:OnTooltipUpdate()
	if not self:ItemValid() then return end

	local cat = tablet:AddCategory("columns", 2, "hideBlankLine", true)

	for unit,val in pairs(self.tagged) do
		if val == true and self:UnitValid(unit) and not core:UnitIsFiltered(self, unit) then
			local color = (UnitInParty(unit) or UnitInRaid(unit)) and string.format("|cff%s", BC:GetHexColor(UnitClass(unit))) or "|cff00ff00"
			local name = unit and (color.. UnitName(unit))
			local icon = self:GetIcon(unit) or questionmark
			local group
			if partyids[unit] then group = partyids[unit]
			elseif GetNumRaidMembers() > 0 and raidunitnum[unit] then
				_,_,group = GetRaidRosterInfo(raidunitnum[unit])
				group = "Group "..group
			end
			cat:AddLine("text", name, "hasCheck", true, "checked", true, "checkIcon", icon,
				"func", self.PutACorkInIt, "arg1", self, "arg2", unit, "arg3", self, "text2", group)
		end
	end
end

