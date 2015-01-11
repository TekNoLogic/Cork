
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a garrison
if level < 90 then return end


local name = "Completed work orders"


local dataobj    = ns:New(name)
dataobj.tiptext  = "Notify you when you are in your garrison and have completed work orders"
dataobj.priority = 20
ns.defaultspc[name.."-enabled"] = true


local function Test(self)
	if not C_Garrison.IsOnGarrisonMap() then return end

	local buildings = C_Garrison.GetBuildings()
	for i,building in pairs(buildings) do
		local id = building.buildingID
		if id then
			local _, _, _, shipmentsReady, shipmentsTotal = C_Garrison.GetLandingPageShipmentInfo(id)
			shipmentsReady = shipmentsReady or 0
			shipmentsTotal = shipmentsTotal or 0

			if shipmentsReady >= 6 then return id end
			if shipmentsTotal > 0 and (shipmentsTotal - shipmentsReady) < 6 then return id end
		end
	end
end


local function RequestRefresh()
	if not C_Garrison.IsOnGarrisonMap() then return end
	C_Garrison.RequestLandingPageShipmentInfo()
end


function dataobj:Scan(...)
	if not ns.dbpc[self.name.."-enabled"] then
		self.player = nil
		return
	end

	local buildingID = Test()
	if buildingID then
		local _, name, _, icon = C_Garrison.GetBuildingInfo(buildingID)
		self.player = ns.IconLine(icon, name)
	else
		self.player = nil
	end
end


ae.RegisterEvent(dataobj, "GARRISON_LANDINGPAGE_SHIPMENTS", "Scan")
ae.RegisterEvent("Cork"..name, "ZONE_CHANGED", RequestRefresh)
ae.RegisterEvent("Cork"..name, "BAG_UPDATE_DELAYED", RequestRefresh)
ae.RegisterEvent("Cork"..name, "SHIPMENT_CRAFTER_INFO", RequestRefresh)
