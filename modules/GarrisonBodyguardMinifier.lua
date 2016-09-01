
local myname, Cork = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Garrison only available at 90
if level < 90 then return end


local dataobj = Cork:GenerateItemSelfBuffer(122298)


local function CheckForBodyguard()
	local buildings = C_Garrison.GetBuildings(LE_GARRISON_TYPE_6_0)

	if not next(buildings) then
		C_Garrison.RequestLandingPageShipmentInfo()
		C_Timer.After(0.25, CheckForBodyguard)
	end

	for i,building in pairs(buildings) do
		if building.buildingID == 27 or building.buildingID == 28 then
			local bg = not not C_Garrison.GetFollowerInfoForBuilding(building.plotID)
			Cork.defaultspc[dataobj.name.."-enabled"] = bg
			return
		end
	end
end


local orig = dataobj.Init
function dataobj:Init()
	orig(self)
	if Cork.defaultspc[self.name.."-enabled"] then CheckForBodyguard() end
	self.Init = nil
end


local zoneids = {}
local function ParseSubzones(id, name, ...)
	zoneids[name] = true
	if select("#", ...) > 0 then return ParseSubzones(...) end
end
local function ParseZones(id, name, ...)
	zoneids[name] = true
	ParseSubzones(GetMapSubzones(id))
	if select("#", ...) > 0 then return ParseZones(...) end
end
ParseZones(GetMapZones(7))


local orig2 = dataobj.TestWithoutResting
function dataobj:Test()
	if not zoneids[GetRealZoneText()] then return end
	return orig2(self)
end


ae.RegisterEvent(dataobj, "ZONE_CHANGED", "Scan")
