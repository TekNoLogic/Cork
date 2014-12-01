
local myname, Cork = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a garrison (lvl 90+)
if level < 90 then return end


local zone = "Frostwall Mine"
if UnitFactionGroup("player") == "Alliance" then
	zone = "Lunarfall Excavation"
end


local function Init(self)
	Cork.defaultspc[self.spellname.."-enabled"] = true
end


local function TestWithoutResting(self)
	if Cork.dbpc[self.spellname.."-enabled"] and not self.HasBuff(self.spells) then
		return self.iconline
	end
end


local function Test(self)
	return not IsResting() and GetSubZoneText() == zone and self:TestWithoutResting()
end


local itemname = GetItemInfo(118897) or "Miner's Coffee"
local buffname, _, icon = GetSpellInfo(176049)
local dataobj = Cork:GenerateSelfBuffer(itemname, icon, buffname)
dataobj.Init = Init
dataobj.Test = Test
dataobj.TestWithoutResting = TestWithoutResting
dataobj.tiplink = "item:118897"
ae.RegisterEvent(dataobj, "ZONE_CHANGED", "Scan")
function dataobj:CorkIt(frame)
	if self.player then return frame:SetManyAttributes("type1", "item", "item1", "item:118897") end
end


local itemname = GetItemInfo(118903) or "Preserved Mining Pick"
local buffname, _, icon = GetSpellInfo(176061)
local dataobj = Cork:GenerateSelfBuffer(itemname, icon, buffname)
dataobj.Init = Init
dataobj.Test = Test
dataobj.TestWithoutResting = TestWithoutResting
dataobj.tiplink = "item:118903"
ae.RegisterEvent(dataobj, "ZONE_CHANGED", "Scan")
function dataobj:CorkIt(frame)
	if self.player then return frame:SetManyAttributes("type1", "item", "item1", "item:118903") end
end
