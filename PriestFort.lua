
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end


local spellname, _, icon = GetSpellInfo(1243)
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine


local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
local dataobj = ldb:NewDataObject("Cork_Fort", {type = "cork"})


local function Test(unit) if UnitExists(unit) and not UnitAura(unit, spellname) then return IconLine(icon, UnitName(unit)) end end
ae.RegisterEvent("Cork_Fort", "UNIT_AURA", function(event, unit) dataobj[unit] = Test(unit) end)
ae.RegisterEvent("Cork_Fort", "PARTY_MEMBERS_CHANGED", function() for i=1,4 do dataobj["party"..i], dataobj["partypet"..i] = Test("party"..i), Test("partypet"..i) end end)
ae.RegisterEvent("Cork_Fort", "RAID_ROSTER_UPDATE", function() for i=1,40 do dataobj["raid"..i], dataobj["radipet"..i] = Test("raid"..i), Test("raidpet"..i) end end)


dataobj.player = Test("player")
for i=1,GetNumPartyMembers() do
	dataobj["party"..i] = Test("party"..i)
	dataobj["partypet"..i] = Test("partypet"..i)
end
for i=1,GetNumRaidMembers() do
	dataobj["raid"..i] = Test("raid"..i)
	dataobj["raidpet"..i] = Test("raidpet"..i)
end


function dataobj:CorkIt(frame)
	for unit in ldb:pairs(self) do
		if SpellCastableOnUnit(spellname, unit) then
			frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", unit)
			return true
		end
	end
end
