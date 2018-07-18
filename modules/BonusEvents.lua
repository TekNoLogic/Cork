
local myname, ns = ...


local WQ_QUEST_ID = 44175
local WQ_BUFF, _, WQ_BUFF_ICON = GetSpellInfo(186404)
local WQ_ICONLINE = ns.IconLine(WQ_BUFF_ICON, "Bonus event quest")


-- You have to be 110 to get the weekly bonus events
if UnitLevel("player") < 110 then return end

local UnitAura = ns.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local dataobj    = ns:New("Bonus Events")
dataobj.tiptext  = "Notify you when there is a weekly Bonus Event quest to accept"
dataobj.priority = 15


function dataobj:Init()
	ns.defaultspc[self.name.."-enabled"] = true
end


local completed
local function IsCompleted()
	completed = completed or GetQuestsCompleted()[WQ_QUEST_ID]
	return completed
end


local function Test()
	if not UnitAura("player", WQ_BUFF) then return end
	if GetQuestLogIndexByID(WQ_QUEST_ID) ~= 0 then return end
	if IsCompleted() then return end
	return WQ_ICONLINE
end


local lastid
function dataobj:Scan()
	if not ns.dbpc[self.name.."-enabled"] then
		self.player = nil
		return
	end

	self.player = Test()
end


ae.RegisterEvent(dataobj, "QUEST_LOG_UPDATE", "Scan")
