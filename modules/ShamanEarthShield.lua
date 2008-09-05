
local _, c = UnitClass("player")
if c ~= "SHAMAN" then return end


local Cork = Cork
local UnitAura = Cork.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local blist = {npc = true, vehicle = true, focus = true, target = true}
local spellname, _, icon = GetSpellInfo(974)
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine


local lasttarget
local dataobj = ldb:NewDataObject("Cork "..spellname, {type = "cork"})


ae.RegisterEvent("Cork "..spellname, "PARTY_MEMBERS_CHANGED", function() if lasttarget and not UnitInParty(lasttarget) then lasttarget, dataobj.custom = nil end end)
ae.RegisterEvent("Cork "..spellname, "RAID_ROSTER_UPDATE", function() if lasttarget and not UnitInRaid(lasttarget) then lasttarget, dataobj.custom = nil end end)
ae.RegisterEvent("Cork "..spellname, "UNIT_PET", function() if lasttarget and not (UnitInParty(lasttarget) or UnitInRaid(lasttarget)) then lasttarget, dataobj.custom = nil end end)
ae.RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit)
	if not Cork.dbpc[spellname.."-enabled"] or blist[unit] then return end
	local name, _, _, _, _, _, _, isMine = UnitAura(unit, spellname)
	if name and isMine then lasttarget, dataobj.custom = UnitName(unit), nil
	elseif not name and UnitName(unit) == lasttarget then dataobj.custom = IconLine(icon, lasttarget, select(2, UnitClass(unit))) end
end)


local function Test(unit)
	if not UnitExists(unit) then return end
	local name, _, _, _, _, _, _, isMine = UnitAura(unit, spellname)
	if not name or not isMine then return end
	lasttarget = UnitName(unit)
	return true
end
local function FindCurrent()
	if Test("player") then return true end
	for i=1,GetNumPartyMembers() do if Test("party"..i) or Test("partypet"..i) then return true end end
	for i=1,GetNumRaidMembers() do if Test("raid"..i) or Test("raidpet"..i) then return true end end
end

function dataobj:Init() FindCurrent(); Cork.defaultspc[spellname.."-enabled"] = GetSpellInfo(spellname) ~= nil end
function dataobj:Scan() if not Cork.dbpc[spellname.."-enabled"] then lasttarget, dataobj.custom = nil end end
function dataobj:CorkIt(frame) if self.custom then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", lasttarget) end end


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
