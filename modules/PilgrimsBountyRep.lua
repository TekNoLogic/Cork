
local myname, ns = ...
local ae = LibStub("AceEvent-3.0")


local maxlevel = GetMaxPlayerLevel()
local itemname = "Pilgrim's Bounty Rep Buff"
local spellname, _, icon = GetSpellInfo(61849)
local dataobj = ns:GenerateSelfBuffer(itemname, icon, spellname)
ns.defaultspc[itemname.."-enabled"] = true

local localizedNames = {
	["deDE"] = "Pilgerfreudenfest",
	["esES"] = "Generosidad del Peregrino",
	["esMX"] = "Generosidad del Peregrino",
	["frFR"] = "Les Bienfaits du pèlerin",
	["itIT"] = "Ringraziamento del Pellegrino",
	["koKR"] = "순례자의 감사절",
	["ptBR"] = "Festa da Fartura",
	["ruRU"] = "Пиршество странников",
	["zhCN"] = "感恩节",
	["zhTW"] = "感恩节",
}
local holidayName = localizedNames[GetLocale()] or "Pilgrim's Bounty"

local function BountyToday()
	return ns.IsHolidayActive(holidayName)
end


function dataobj:Test()
	if UnitLevel("player") < maxlevel then return false end
	return BountyToday() and self:TestWithoutResting()
end


function dataobj:Init()
	if UnitLevel("player") == maxlevel then C_Calendar.OpenCalendar() end
end


ae.RegisterEvent(dataobj, "CALENDAR_UPDATE_EVENT_LIST", "Scan")
dataobj.tiplink = "spell:61849"
dataobj.CorkIt = nil
