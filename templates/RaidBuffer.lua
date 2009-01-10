
local Cork = Cork
local UnitAura = Cork.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local blist = {npc = true, vehicle = true}

function Cork:GenerateRaidBuffer(spellname, multispellname, icon)
	Cork.hasgroupspell = true

	local multispell = multispellname and GetSpellInfo(multispellname)

	local SpellCastableOnUnit, IconLine = self.SpellCastableOnUnit, self.IconLine

	local dataobj = ldb:NewDataObject("Cork "..spellname, {type = "cork"})

	function dataobj:Init() Cork.defaultspc[spellname.."-enabled"] = GetSpellInfo(spellname) ~= nil end

	local function Test(unit)
		if not Cork.dbpc[spellname.."-enabled"] or not Cork:ValidUnit(unit) then return end

		if not (UnitAura(unit, spellname) or multispellname and UnitAura(unit, multispellname)) then
			local _, token = UnitClass(unit)
			return IconLine(icon, UnitName(unit), token)
		end
	end
	Cork:RegisterRaidEvents(spellname, dataobj, Test)
	dataobj.Scan = Cork:GenerateRaidScan(Test)


	local raidneeds = {}
	function dataobj:CorkIt(frame, playersonly)
		multispell = multispell or multispellname and GetSpellInfo(multispellname) -- Refresh in case the player has learned this since login

		if multispell then
			local num = dataobj.player and 1 or 0
			for i=1,GetNumPartyMembers() do num = num + (dataobj["party"..i] and (IsSpellInRange(multispell, "party"..i) or IsSpellInRange(spellname, "party"..i)) and 1 or 0) end
			if num >= Cork.dbpc.multithreshold then return frame:SetManyAttributes("type1", "spell", "spell", multispell, "unit", "player") end

			if GetNumRaidMembers() > 0 then for i in pairs(raidneeds) do raidneeds[i] = nil end end
			for i=1,GetNumRaidMembers() do
				local _, _, subgroup, _, _, _, zone, online, dead = GetRaidRosterInfo(i)
				raidneeds[subgroup] = (raidneeds[subgroup] or 0) + (dataobj["raid"..i] and zone and online and not dead and (IsSpellInRange(multispell, "raid"..i) or IsSpellInRange(spellname, "raid"..i)) and 1 or 0)
				if raidneeds[subgroup] >= Cork.dbpc.multithreshold then return frame:SetManyAttributes("type1", "spell", "spell", multispell, "unit", "raid"..i) end
			end
		end

		if self.player and SpellCastableOnUnit(spellname, "player") then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "player") end
		for unit in ldb:pairs(self) do if (not playersonly or not Cork.petunits[unit]) and SpellCastableOnUnit(spellname, unit) then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", unit) end end
	end
end


function Cork:ValidUnit(unit, nopets)
	if blist[unit] or not UnitExists(unit) or (UnitIsPlayer(unit) and not UnitIsConnected(unit))
		or (Cork.petunits[unit] and (nopets or not Cork.dbpc.castonpets))
		or (unit ~= "player" and UnitIsUnit(unit, "player"))
		or (unit == "target" and (UnitIsUnit("target", "focus") or not UnitCanAssist("player", unit) or not UnitPlayerControlled(unit) or UnitIsEnemy("player", unit)))
		or (unit == "focus" and not UnitCanAssist("player", unit)) then return end
	return true
end


function Cork:RegisterRaidEvents(spellname, dataobj, Test)
	ae.RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit) dataobj[unit] = Test(unit) end)
	ae.RegisterEvent("Cork "..spellname, "PARTY_MEMBERS_CHANGED", function() for i=1,4 do dataobj["party"..i], dataobj["partypet"..i] = Test("party"..i), Test("partypet"..i) end end)
	ae.RegisterEvent("Cork "..spellname, "RAID_ROSTER_UPDATE", function() for i=1,40 do dataobj["raid"..i], dataobj["raidpet"..i] = Test("raid"..i), Test("raidpet"..i) end end)
	ae.RegisterEvent("Cork "..spellname, "UNIT_PET", function(event, unit) if Cork.petmappings[unit] then dataobj[Cork.petmappings[unit]] = Test(Cork.petmappings[unit]) end end)
	local function TestTargetandFocus() dataobj.target, dataobj.focus = Test("target"), Test("focus") end
	ae.RegisterEvent("Cork "..spellname, "PLAYER_TARGET_CHANGED", TestTargetandFocus)
	ae.RegisterEvent("Cork "..spellname, "PLAYER_FOCUS_CHANGED", TestTargetandFocus)
end


function Cork:GenerateRaidScan(Test)
	return function(self)
		self.target, self.focus = Test("target"), Test("focus")
		self.player, self.pet = Test("player"), Test("pet")
		for i=1,GetNumPartyMembers() do self["party"..i], self["partypet"..i] = Test("party"..i), Test("partypet"..i) end
		for i=1,GetNumRaidMembers() do self["raid"..i], self["raidpet"..i] = Test("raid"..i), Test("raidpet"..i) end
	end
end
