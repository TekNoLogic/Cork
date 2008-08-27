
local Cork = Cork
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local blist = {npc = true, vehicle = true}

function Cork:GenerateRaidBuffer(spellname, multispellname, icon)
	local multispell = multispellname and GetSpellInfo(multispellname)

	local SpellCastableOnUnit, IconLine = self.SpellCastableOnUnit, self.IconLine
	local thresh = 2

	local defaults = Cork.defaultspc
	defaults[spellname.."-enabled"] = true
	defaults[spellname.."-castonpets"] = false
	defaults[spellname.."-multithreshold"] = 2


	local dataobj = ldb:NewDataObject("Cork "..spellname, {type = "cork"})


	local function Test(unit)
		if not Cork.dbpc[spellname.."-enabled"] or blist[unit] or
			not UnitExists(unit) or (UnitIsPlayer(unit) and not UnitIsConnected(unit))
			or (Cork.petunits[unit] and not Cork.dbpc[spellname.."-castonpets"])
			or (unit ~= "player" and UnitIsUnit(unit, "player"))
			or (unit == "target" and (not UnitCanAssist("player", unit) or not UnitPlayerControlled(unit) or UnitIsEnemy("player", unit)))
			or (unit == "focus" and not UnitCanAssist("player", unit)) then return end

		if not (UnitAura(unit, spellname) or multispellname and UnitAura(unit, multispellname)) then
			local _, token = UnitClass(unit)
			return IconLine(icon, UnitName(unit), token)
		end
	end
	ae.RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit) dataobj[unit] = Test(unit) end)
	ae.RegisterEvent("Cork "..spellname, "PARTY_MEMBERS_CHANGED", function() for i=1,4 do dataobj["party"..i], dataobj["partypet"..i] = Test("party"..i), Test("partypet"..i) end end)
	ae.RegisterEvent("Cork "..spellname, "RAID_ROSTER_UPDATE", function() for i=1,40 do dataobj["raid"..i], dataobj["raidpet"..i] = Test("raid"..i), Test("raidpet"..i) end end)
	ae.RegisterEvent("Cork "..spellname, "UNIT_PET", function(event, unit) if Cork.petmappings[unit] then dataobj[Cork.petmappings[unit]] = Test(Cork.petmappings[unit]) end end)
	ae.RegisterEvent("Cork "..spellname, "PLAYER_TARGET_CHANGED", function() dataobj.target = Test("target") end)
	ae.RegisterEvent("Cork "..spellname, "PLAYER_FOCUS_CHANGED", function() dataobj.focus = Test("focus") end)


	function dataobj:Scan()
		self.player, self.pet = Test("player"), Test("pet")
		for i=1,GetNumPartyMembers() do self["party"..i], self["partypet"..i] = Test("party"..i), Test("partypet"..i) end
		for i=1,GetNumRaidMembers() do self["raid"..i], self["raidpet"..i] = Test("raid"..i), Test("raidpet"..i) end
	end


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

		if self.player and SpellCastableOnUnit(spellname, "player") then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "player") end
		for unit in ldb:pairs(self) do if SpellCastableOnUnit(spellname, unit) then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", unit) end end
	end


	----------------------
	--      Config      --
	----------------------

	local GAP = 8
	local tekcheck = LibStub("tekKonfig-Checkbox")

	local frame = CreateFrame("Frame", nil, UIParent)
	frame.name = spellname
	frame.parent = "Cork"
	frame:Hide()

	frame:SetScript("OnShow", function()
		local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Cork - "..spellname, "These settings are saved on a per-char basis.")

		local enabled = tekcheck.new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
		enabled.tiptext = "Toggle this module."
		local checksound = enabled:GetScript("OnClick")
		enabled:SetScript("OnClick", function(self)
			checksound(self)
			Cork.dbpc[spellname.."-enabled"] = not Cork.dbpc[spellname.."-enabled"]
			dataobj:Scan()
		end)

		local castonpets = tekcheck.new(frame, nil, "Cast on group pets", "TOPLEFT", enabled, "BOTTOMLEFT", 0, -GAP)
		castonpets.tiptext = "Pets need buffs too!  When disabled you can still cast on a pet by targetting it directly."
		castonpets:SetScript("OnClick", function(self)
			checksound(self)
			Cork.dbpc[spellname.."-castonpets"] = not Cork.dbpc[spellname.."-castonpets"]
			dataobj:Scan()
		end)

		local function Update(self)
			enabled:SetChecked(Cork.dbpc[spellname.."-enabled"])
			castonpets:SetChecked(Cork.dbpc[spellname.."-castonpets"])
		end

		frame:SetScript("OnShow", Update)
		Update(frame)
	end)

	InterfaceOptions_AddCategory(frame)

end
