
local myname, Cork = ...
local UnitAura = Cork.UnitAura or UnitAura
local IsSpellInRange = Cork.IsSpellInRange
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local partyunits, raidunits = {}, {}
for i=1,4 do partyunits["party"..i] = i end
for i=1,40 do raidunits["raid"..i] = i end
local function ValidUnit(unit, nopets)
	if not (unit == "player" or partyunits[unit] or raidunits[unit]) or not UnitExists(unit) or (not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) or UnitInVehicle(unit))
		or raidunits[unit] and select(3, GetRaidRosterInfo(raidunits[unit])) > Cork.dbpc.raid_thresh then return end

	return true
end


function Cork:GenerateItemBuffer(class, itemid, spellid, classspellid)
	local multiclass = type(class) == "table"
	if Cork.MYCLASS == class or multiclass and class[Cork.MYCLASS] then return end

	Cork.hasgroupspell = true

	local spellname = GetSpellInfo(spellid)
	local classspellname = GetSpellInfo(classspellid)
	local itemname = GetItemInfo(itemid)
	local icon = GetItemIcon(itemid)
	if not itemname then
		GameTooltip:SetHyperlink("item:"..itemid)
		return print("Cork cannot find cached info for "..spellname.."'s buff item.  Please reload your UI to activate the module.")
	end

	local SpellCastableOnUnit, IconLine = self.SpellCastableOnUnit, self.IconLine

	local dataobj = ldb:NewDataObject("Cork "..itemname, {type = "cork", tiplink = "item:"..itemid})

	Cork.defaultspc[itemname.."-enabled"] = true

	local hasclass
	local function TestUnit(unit)
		local _, c = UnitClass(unit)
		return class == c or multiclass and class[c]
	end
	local function ScanForClass()
		hasclass = false
		for i=1,GetNumRaidMembers() do if TestUnit("raid"..i) then hasclass = true; return end end
		for i=1,GetNumPartyMembers() do if TestUnit("party"..i) then hasclass = true; return end end
	end

	local function Test(unit)
		if hasclass or not Cork.dbpc[itemname.."-enabled"] or (IsResting() and not Cork.db.debug) or not ValidUnit(unit) or (GetItemCount(itemid) or 0) == 0 then return end
		if unit == "player" and (GetNumRaidMembers() + GetNumPartyMembers()) == 0 then return end

		if not (UnitAura(unit, classspellname) or UnitAura(unit, spellname)) then
			local _, token = UnitClass(unit)
			return IconLine(icon, UnitName(unit), token)
		end
	end

	function dataobj:Scan()
		ScanForClass()
		self.player = Test("player")
		for i=1,4 do self["party"..i] = Test("party"..i) end
		for i=1,40 do self["raid"..i] = Test("raid"..i) end
	end

	ae.RegisterEvent(dataobj, "PARTY_MEMBERS_CHANGED", "Scan")
	ae.RegisterEvent(dataobj, "RAID_ROSTER_UPDATE", "Scan")
	ae.RegisterEvent(dataobj, "PLAYER_UPDATE_RESTING", "Scan")
	ae.RegisterEvent("Cork "..itemname, "UNIT_AURA", function(event, unit) dataobj[unit] = Test(unit) end)


	dataobj.RaidLine = IconLine(icon, itemname.." (%d)")


	local raidneeds = {}
	function dataobj:CorkIt(frame, playersonly)
		if (GetItemCount(itemid) or 0) == 0 then return end

		local num = 0
		for i=1,GetNumRaidMembers() do
			local _, _, _, _, _, _, zone, online, dead = GetRaidRosterInfo(i)
			num = num + (dataobj["raid"..i] and zone and online and not dead and (IsItemInRange(17202, "raid"..i) == 1) and 1 or 0)
			if num >= Cork.dbpc.multithreshold then return frame:SetManyAttributes("type1", "item", "item1", "item:"..itemid) end
		end

		num = dataobj.player and 1 or 0
		for i=1,GetNumPartyMembers() do num = num + (dataobj["party"..i] and (IsItemInRange(17202, "party"..i) == 1) and 1 or 0) end
		if num >= Cork.dbpc.multithreshold then return frame:SetManyAttributes("type1", "item", "item1", "item:"..itemid) end
	end
end
