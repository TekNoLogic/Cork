
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a class hall
if level < 101 then return end


local name = "Completed class hall work orders"


local dataobj    = ns:New(name)
dataobj.tiptext  = "Notify you when you are resting and have completed work orders"
dataobj.priority = 20
ns.defaultspc[name.."-enabled"] = true


local shipment_ids = {}
local function Test(shipment_id)
	shipment_ids[shipment_id] = true

	local name, icon, capacity, ready, total =
		C_Garrison.GetLandingPageShipmentInfoByContainerID(shipment_id)

	if name and ready > 0 then
		local txt = string.format("%s (%d/%d)", name, ready, total)
		return ns.IconLine(icon, txt)
	end
end


local function RequestRefresh()
	if not ns.dbpc[name.."-enabled"] or not IsResting() then return end
	C_Garrison.RequestLandingPageShipmentInfo()
end


function dataobj:Scan(...)
	if not ns.dbpc[self.name.."-enabled"] or not IsResting() then
		for id in pairs(shipment_ids) do self["shipment"..id] = nil end
		return
	end

	local shipments = C_Garrison.GetLooseShipments(LE_GARRISON_TYPE_7_0)
	for i,shipment_id in pairs(shipments) do
		self["shipment"..shipment_id] = Test(shipment_id)
	end
end


ae.RegisterEvent(dataobj, "GARRISON_LANDINGPAGE_SHIPMENTS", "Scan")
ae.RegisterEvent(dataobj, "GARRISON_TALENT_UPDATE", "Scan")
ae.RegisterEvent(dataobj, "GARRISON_TALENT_COMPLETE", "Scan")
ae.RegisterEvent(dataobj, "GARRISON_SHIPMENT_RECEIVED", RequestRefresh)
ae.RegisterEvent(dataobj, "ZONE_CHANGED", RequestRefresh)
