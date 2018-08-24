
local myname, ns = ...
local ae = LibStub("AceEvent-3.0")


local maxlevel = GetMaxPlayerLevel()
local itemname = "Darkmoon EXP Buff"
local spellname, _, icon = GetSpellInfo(46668)
local hatspell = GetSpellInfo(136583)
local dataobj = ns:GenerateSelfBuffer(itemname, icon, spellname, hatspell)
ns.defaultspc[itemname.."-enabled"] = true

local localizedNames = {
	["deDE"] = "Dunkelmond-Jahrmarkt",
	["esES"] = "Feria de la Luna Negra",
	["esMX"] = "Feria de la Luna Negra",
	["frFR"] = "Foire de Sombrelune",
	["itIT"] = "Fiera di Lunacupa",
	["koKR"] = "다크문 축제",
	["ptBR"] = "Feira de Negraluna",
	["ruRU"] = "Ярмарка Новолуния",
	["zhCN"] = "暗月马戏团",
	["zhTW"] = "暗月马戏团",
}
local holidayName = localizedNames[GetLocale()] or "Darkmoon Faire"

local function DarkmoonToday()
	return ns.IsHolidayActive(holidayName)
end


function dataobj:Test()
	if UnitLevel("player") == maxlevel then return false end
	return DarkmoonToday() and self:TestWithoutResting()
end


function dataobj:Init()
	if UnitLevel("player") < maxlevel then C_Calendar.OpenCalendar() end
end


ae.RegisterEvent(dataobj, "CALENDAR_UPDATE_EVENT_LIST", "Scan")
dataobj.tiplink = "spell:46668"
dataobj.CorkIt = nil
