
local myname, ns = ...
local ae = LibStub("AceEvent-3.0")


local maxlevel = GetMaxPlayerLevel()
local itemname = "Darkmoon EXP Buff"
local spellname, _, icon = GetSpellInfo(46668)
local hatspell = GetSpellInfo(136583)
local dataobj = ns:GenerateSelfBuffer(itemname, icon, spellname, hatspell)
ns.defaultspc[itemname.."-enabled"] = true


local function DarkmoonToday()
	return ns.IsHolidayActive("Darkmoon Faire")
end


function dataobj:Test()
	if UnitLevel("player") == maxlevel then return false end
	return DarkmoonToday() and self:TestWithoutResting()
end


function dataobj:Init()
	if UnitLevel("player") < maxlevel then OpenCalendar() end
end


ae.RegisterEvent(dataobj, "CALENDAR_UPDATE_EVENT_LIST", "Scan")
dataobj.tiplink = "spell:46668"
dataobj.CorkIt = nil
