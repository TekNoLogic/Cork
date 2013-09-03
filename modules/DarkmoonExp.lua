
local myname, Cork = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


local function DarkmoonToday()
	local _, _, day = CalendarGetDate()
	local title, _, _, calendarType, sequenceType, eventType, texture
	local i = 1
	repeat
		title, _, _, calendarType, sequenceType, eventType, texture = CalendarGetDayEvent(0, day, i)
		if title == "Darkmoon Faire" then return true end
		i = i + 1
	until not title
end


local maxlevel = GetMaxPlayerLevel()
local itemname = "Darkmoon EXP Buff"
local spellname, _, icon = GetSpellInfo(46668)
local hatspell = GetSpellInfo(136583)
local dataobj = Cork:GenerateSelfBuffer(itemname, icon, spellname, hatspell)
function dataobj:Test() return DarkmoonToday() and self:TestWithoutResting() end
function dataobj:Init()
	Cork.defaultspc[itemname.."-enabled"] = level < maxlevel
	if level < maxlevel then OpenCalendar() end
end
ae.RegisterEvent(dataobj, "CALENDAR_UPDATE_EVENT_LIST", "Scan")
dataobj.tiplink = "spell:46668"
dataobj.CorkIt = nil
