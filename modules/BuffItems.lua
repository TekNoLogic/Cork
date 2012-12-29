
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

local itemname = "Darkmoon EXP Buff"
local spellname, _, icon = GetSpellInfo(46668)
local dataobj = Cork:GenerateSelfBuffer(itemname, icon, spellname)
local oldtest = dataobj.Test
function dataobj.Test() return DarkmoonToday() and oldtest() end
function dataobj:Init()
	Cork.defaultspc[itemname.."-enabled"] = level < 90
	if level < 90 then OpenCalendar() end
end
ae.RegisterEvent(dataobj, "CALENDAR_UPDATE_EVENT_LIST", "Scan")
dataobj.tiplink = "spell:46668"
dataobj.CorkIt = nil


-- Items only available at 80
if level < 80 then return end


-- Drums of Forgotten Kings
Cork:GenerateItemBuffer({PALADIN = true, DRUID = true, MONK = true}, 49633, 69378, 20217)


-- Runescroll of Fortitude
local id = level < 85 and 49632 or level < 90 and 62251 or 79257
Cork:GenerateItemBuffer("PRIEST", id, 69377, 21562)


-- Only available to alchys
local itemname = GetItemInfo(75525) or "Alchemist's Flask"
local dataobj = Cork:GenerateSelfBuffer(itemname, GetItemIcon(75525),
	GetSpellInfo(79469),  -- Flask of Steelskin
	GetSpellInfo(79470),  -- Flask of the Draconic Mind
	GetSpellInfo(79471),  -- Flask of the Winds
	GetSpellInfo(79472),  -- Flask of Titanic Strength
	GetSpellInfo(94160),  -- Flask of Flowing Water
	GetSpellInfo(92679),  -- Flask of Battle (Guild Flask)
	GetSpellInfo(79638),  -- Flask of Enhancement - Strength
	GetSpellInfo(79639),  -- Flask of Enhancement - Agilty
	GetSpellInfo(79640), -- Flask of Enhancement - Intellect
	GetSpellInfo(105689), -- Flask of Spring Blossoms
	GetSpellInfo(105691), -- Flask of the Warm Sun
	GetSpellInfo(105693), -- Flask of Falling Leaves
	GetSpellInfo(105694), -- Flask of the Earth
	(GetSpellInfo(105696)) -- Flask of Winter's Bite
)
dataobj.tiplink = "item:75525"

function dataobj:Init() Cork.defaultspc[itemname.."-enabled"] = GetItemCount(75525) > 0 end

function dataobj:CorkIt(frame)
	if self.player then return frame:SetManyAttributes("type1", "item", "item1", "item:75525") end
end
