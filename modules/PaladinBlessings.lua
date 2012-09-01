
local myname, Cork = ...
if Cork.MYCLASS ~= "PALADIN" then return end

local UnitAura = UnitAura
local IsSpellInRange, SpellCastableOnUnit, IconLine = Cork.IsSpellInRange, Cork.SpellCastableOnUnit, Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local blist = {npc = true, vehicle = true}
for i=1,5 do blist["arena"..i], blist["arenapet"..i] = true, true end


-- Mark of the Wild and Blessing or Kings are now the same buff
-- Blessing of Might is the only other blessing
-- Both of these hit the entire raid now
-- and pet are not buffable anymore

-- So, this is the logic we need:
-- If the unit has a buff from you, or has both kings/mark and might, skip them
-- If there is a druid in the group, you have the kings drums, or units have kings/forgotten kings on them, cast might
-- Otherwise, cast kings

local MARK, FORGOTTEN_KINGS, KINGS, _, KINGSICON = GetSpellInfo(1126), GetSpellInfo(69378), GetSpellInfo(20217)
local MIGHT, _, MIGHTICON = GetSpellInfo(19740)
local MIGHTRAIDLINE, KINGSRAIDLINE = IconLine(MIGHTICON, "Blessing (%d)"), IconLine(KINGSICON, "Blessing (%d)")


local function FurryInGroup()
	for i=1,GetNumGroupMembers() do if select(6, GetRaidRosterInfo(i)) == "DRUID" then return true end end
end


local function NeededBlessing(unit)
	local hasMark = UnitAura(unit, MARK)
	local hasForgottenKings = UnitAura(unit, FORGOTTEN_KINGS)
	local hasKings, _, _, _, _, _, _, myKings = UnitAura(unit, KINGS)
	local hasMight, _, _, _, _, _, _, myMight = UnitAura(unit, MIGHT)
	local drummer = GetItemCount(49633) > 0
	if myKings or myMight or (hasMark or hasKings) and hasMight then return end
	if (hasMark or hasKings or hasForgottenKings or drummer or FurryInGroup() or select(2, UnitClass(unit)) == "DRUID") and not hasMight then return MIGHT end
	return KINGS
end


local defaults = Cork.defaultspc
defaults["Blessings-enabled"] = true


local dataobj = ldb:NewDataObject("Cork Blessings", {type = "cork", tiptext = "Attempts to pick the best blessing to cast based on your group.  Kings is preferred, except in cases where it can be provided by another means like a druid, forgotten kings drums, or another pally.\n\nNote: the icon will not always show which spell will be cast, that is determined at the time you cast."})

local unitspells = {}
local function Test(unit)
	if not Cork.dbpc["Blessings-enabled"] or (IsResting() and not Cork.db.debug) or not Cork:ValidUnit(unit, true) then wipe(unitspells); return end
	unitspells[unit] = NeededBlessing(unit)
	if unitspells[unit] then
		local icon = (unitspells[unit] == KINGS) and KINGSICON or MIGHTICON
		local _, class = UnitClass(unit)
		dataobj.RaidLine = KINGSRAIDLINE
		for _,spellname in pairs(unitspells) do if spellname == MIGHT then dataobj.RaidLine = MIGHTRAIDLINE end end
		return IconLine(icon, UnitName(unit), class)
	end
end
Cork:RegisterRaidEvents("Blessings", dataobj, Test)
dataobj.Scan = Cork:GenerateRaidScan(Test)

local hadfurry
local function ScanGroupForFurry()
	local hasfurry = FurryInGroup()
	if hadfurry ~= hasfurry then dataobj:Scan() end
	hadfurry = hasfurry
end
ae.RegisterEvent(dataobj, "PARTY_MEMBERS_CHANGED", function() for i=1,4 do dataobj["party"..i] = Test("party"..i) end end)
ae.RegisterEvent(dataobj, "RAID_ROSTER_UPDATE", function() for i=1,40 do dataobj["raid"..i] = Test("raid"..i) end end)
ae.RegisterEvent(dataobj, "PLAYER_UPDATE_RESTING", "Scan")

dataobj.RaidLine = KINGSRAIDLINE

function dataobj:CorkIt(frame)
	for unit in ldb:pairs(self) do
		if Cork.petmappings[unit] and NeededBlessing(unit) == MIGHT and SpellCastableOnUnit(MIGHT, unit) then
			-- unit is in group and needs might, so everyone gets it
			return frame:SetManyAttributes("type1", "spell", "spell", MIGHT, "unit", unit)
		end
	end
	for unit in ldb:pairs(self) do
		-- No one in group needed might
		if Cork.petmappings[unit] and SpellCastableOnUnit(KINGS, unit) then
			-- buff the group with kings
			return frame:SetManyAttributes("type1", "spell", "spell", KINGS, "unit", unit)
		elseif not Cork.petmappings[unit] then
			-- Unit isn't in group, so give them whatever is needed
			local spell = NeededBlessing(unit)
			if SpellCastableOnUnit(spell, unit) then return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", unit) end
		end
	end
end
