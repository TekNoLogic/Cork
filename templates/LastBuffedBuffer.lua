
local myname, Cork = ...
local UnitAura = Cork.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
local blist = {npc = true, vehicle = true, focus = true, target = true}
for i=1,5 do blist["arena"..i], blist["arenapet"..i] = true, true end


function Cork:GenerateLastBuffedBuffer(spellname, icon, ignoreself)
	local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine


	local lasttarget
	local dataobj = ldb:NewDataObject("Cork "..spellname, {type = "cork", tiplink = GetSpellLink(spellname)})


	local f = CreateFrame("Frame")
	f:Hide()

	local endtime, elapsed
	local function Test()
		if (IsResting() and not Cork.db.debug) then return end
		if not Cork.dbpc[spellname.."-enabled"] or not lasttarget then
			f:Hide()
			return
		end

		local start, duration = GetSpellCooldown(spellname)
		if start == 0 then
			if not UnitAura(lasttarget, spellname) then return IconLine(icon, lasttarget, select(2, UnitClass(lasttarget))) end
			return
		end
		endtime = start + duration
		f:Show()
	end


	ae.RegisterEvent("Cork "..spellname, "PLAYER_UPDATE_RESTING", function() dataobj.custom = Test() end)
	ae.RegisterEvent("Cork "..spellname, "PARTY_MEMBERS_CHANGED", function() if lasttarget and not UnitInParty(lasttarget) then lasttarget, dataobj.custom = nil end end)
	ae.RegisterEvent("Cork "..spellname, "RAID_ROSTER_UPDATE", function() if lasttarget and not UnitInRaid(lasttarget) then lasttarget, dataobj.custom = nil end end)
	ae.RegisterEvent("Cork "..spellname, "UNIT_PET", function() if lasttarget and not (UnitInParty(lasttarget) or UnitInRaid(lasttarget)) then lasttarget, dataobj.custom = nil end end)
	ae.RegisterEvent("Cork "..spellname, "UNIT_SPELLCAST_SUCCEEDED", function(event, unit, spell) if unit == "player" and spell == spellname then dataobj.custom = Test() end end)
	ae.RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit)
		if not Cork.dbpc[spellname.."-enabled"] or blist[unit] then return end
		local name, _, _, _, _, _, _, caster = UnitAura(unit, spellname)
		if name and caster and UnitIsUnit('player', caster) and (not ignoreself or not UnitIsUnit('player', unit)) then lasttarget, dataobj.custom = UnitName(unit), nil
		elseif not name and UnitName(unit) == lasttarget then dataobj.custom = Test() end
	end)


	local function TestUnit(unit)
		if not UnitExists(unit) or GetNumGroupMembers() == 0 then return end
		local name, _, _, _, _, _, _, caster = UnitAura(unit, spellname)
		if not name or not caster or not UnitIsUnit('player', caster) then return end
		lasttarget = UnitName(unit)
		return true
	end
	local function FindCurrent()
		if TestUnit("player") then return true end
		for i=1,GetNumSubgroupMembers() do if TestUnit("party"..i) or TestUnit("partypet"..i) then return true end end
		for i=1,GetNumGroupMembers() do if TestUnit("raid"..i) or TestUnit("raidpet"..i) then return true end end
	end

	function dataobj:Init() FindCurrent(); Cork.defaultspc[spellname.."-enabled"] = GetSpellInfo(spellname) ~= nil end
	function dataobj:Scan() if not Cork.dbpc[spellname.."-enabled"] then lasttarget, dataobj.custom = nil end end
	function dataobj:CorkIt(frame) if self.custom then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", lasttarget) end end

	f:SetScript("OnShow", function() elapsed = GetTime() end)
	f:SetScript("OnHide", function() dataobj.custom, endtime = Test() end)
	f:SetScript("OnUpdate", function(self, elap)
		elapsed = elapsed + elap
		if not endtime or elapsed >= endtime then self:Hide() end
	end)


	----------------------
	--      Config      --
	----------------------

	local frame = CreateFrame("Frame", nil, Cork.config)
	frame:SetWidth(1) frame:SetHeight(1)
	dataobj.configframe = frame
	frame:Hide()

	frame:SetScript("OnShow", function()
		local butt = LibStub("tekKonfig-Button").new_small(frame, "RIGHT")
		butt:SetWidth(60) butt:SetHeight(18)
		butt:SetText("Clear")
		butt:SetScript("OnClick", function(self) self:Hide() lasttarget, dataobj.custom = nil end)

		local text = butt:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
		text:SetPoint("RIGHT", butt, "LEFT", -4, 0)

		local function Refresh()
			if lasttarget then
				butt:Show()
				text:SetText(lasttarget)
			else butt:Hide() end
		end

		ldb.RegisterCallback("Cork "..spellname, "LibDataBroker_AttributeChanged_Cork "..spellname, Refresh)

		frame:SetScript("OnShow", Refresh)
		Refresh()
	end)
end
