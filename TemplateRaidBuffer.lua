
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


function Cork:GenerateRaidBuffer(spellname, multispellname, icon)
	local multispell = multispellname and GetSpellInfo(multispellname)

	local SpellCastableOnUnit, IconLine = self.SpellCastableOnUnit, self.IconLine
	local thresh = 2

	local dataobj = ldb:NewDataObject("Cork "..spellname, {type = "cork"})


	local function Test(unit)
		if not UnitExists(unit) or (UnitIsPlayer(unit) and not UnitIsConnected(unit))
			or (unit ~= "player" and UnitIsUnit(unit, "player"))
			or (unit == "target" and (not UnitIsPlayer(unit) or UnitIsEnemy("player", unit)))
			or (unit == "focus" and not UnitCanAssist("player", unit)) then return end

		if not (UnitAura(unit, spellname) or multispellname and UnitAura(unit, multispellname)) then return IconLine(icon, UnitName(unit)) end
	end
	ae.RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit) dataobj[unit] = Test(unit) end)
	ae.RegisterEvent("Cork "..spellname, "PARTY_MEMBERS_CHANGED", function() for i=1,4 do dataobj["party"..i], dataobj["partypet"..i] = Test("party"..i), Test("partypet"..i) end end)
	ae.RegisterEvent("Cork "..spellname, "RAID_ROSTER_UPDATE", function() for i=1,40 do dataobj["raid"..i], dataobj["raidpet"..i] = Test("raid"..i), Test("raidpet"..i) end end)
	ae.RegisterEvent("Cork "..spellname, "UNIT_PET", function(event, unit) dataobj[Cork.petmappings[unit]] = Test(Cork.petmappings[unit]) end)
	ae.RegisterEvent("Cork "..spellname, "PLAYER_TARGET_CHANGED", function() dataobj.target = Test("target") end)
	ae.RegisterEvent("Cork "..spellname, "PLAYER_FOCUS_CHANGED", function() dataobj.focus = Test("focus") end)

	dataobj.player = Test("player")
	for i=1,GetNumPartyMembers() do dataobj["party"..i], dataobj["partypet"..i] = Test("party"..i), Test("partypet"..i) end
	for i=1,GetNumRaidMembers() do dataobj["raid"..i], dataobj["raidpet"..i] = Test("raid"..i), Test("raidpet"..i) end


	local raidneeds = {}
	function dataobj:CorkIt(frame)
		multispell = multispell or multispellname and GetSpellInfo(multispellname) -- Refresh in case the player has learned this since login

		if multispell then
			local num = dataobj.player and 1 or 0
			for i=1,GetNumPartyMembers() do num = num + (dataobj["party"..i] and IsSpellInRange(multispell, "party"..i) and 1 or 0) end
			if num >= thresh then return frame:SetManyAttributes("type1", "spell", "spell", multispell, "unit", "player") end

			if GetNumRaidMembers() > 0 then for i in pairs(raidneeds) do raidneeds[i] = nil end end
			for i=1,GetNumRaidMembers() do
				local _, _, subgroup, _, _, _, zone, online, dead = GetRaidRosterInfo(i)
				raidneeds[subgroup] = (raidneeds[subgroup] or 0) + (zone and online and not dead and IsSpellInRange(multispell, "raid"..i) and 1 or 0)
				if raidneeds[subgroup] >= thresh then return frame:SetManyAttributes("type1", "spell", "spell", multispell, "unit", "raid"..i) end
			end
		end

		for unit in ldb:pairs(self) do if SpellCastableOnUnit(spellname, unit) then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", unit) end end
	end
end
