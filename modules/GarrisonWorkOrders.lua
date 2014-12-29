
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a lvl3 garrison
if level < 90 then return end


local name = "Completed work orders"
local iconline = ns.IconLine("Interface\\ICONS\\inv_garrison_resource", name)


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
			local _, _, _, shipmentsReady = C_Garrison.GetLandingPageShipmentInfo(id)
			if (shipmentsReady or 0) >= 4 then return true end
		end
	end
end


local function RequestRefresh()
	if not C_Garrison.IsOnGarrisonMap() then return end
	C_Garrison.RequestLandingPageShipmentInfo()
end


function dataobj:Scan(...)
	if ns.dbpc[self.name.."-enabled"] and Test() then
		self.player = iconline
	else
		self.player = nil
	end
end


ae.RegisterEvent(dataobj, "GARRISON_LANDINGPAGE_SHIPMENTS", "Scan")
ae.RegisterEvent("Cork"..name, "ZONE_CHANGED", RequestRefresh)
ae.RegisterEvent("Cork"..name, "BAG_UPDATE_DELAYED", RequestRefresh)
