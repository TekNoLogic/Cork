
local myname, ns = ...
local ae = LibStub("AceEvent-3.0")


local maxlevel = GetMaxPlayerLevel()
local itemname = UnitLevel("player") < maxlevel and "Darkmoon EXP Buff" or "Darkmoon Rep Buff"
local spellname, _, icon = GetSpellInfo(46668)
local hatspell = GetSpellInfo(136583)
local dataobj = ns:GenerateSelfBuffer(itemname, icon, spellname, hatspell)
ns.defaultspc[itemname.."-enabled"] = true


local function DarkmoonToday()
	return ns.IsHolidayActive("Darkmoon Faire")
end


function dataobj:Test()
	return DarkmoonToday() and self:TestWithoutResting()
end


function dataobj:Init()
end


ae.RegisterEvent(dataobj, "CALENDAR_UPDATE_EVENT_LIST", "Scan")
dataobj.tiplink = "spell:46668"
dataobj.CorkIt = nil
