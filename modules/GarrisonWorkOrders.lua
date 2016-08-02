
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


local blacklist = {
	[29] = true,
	[136] = true,
	[137] = true,
}
local function Test(self, building)
	if not ns.InGarrison() then return end

	local id = building.buildingID
	if id then
		local _, _, _, numready, total = C_Garrison.GetLandingPageShipmentInfo(id)
		numready = numready or 0
		total = total or 0

		if total > 0 and numready == total then return true end
		if not blacklist[id] and total > 0 and (total - numready) <= 9 then
			return true
		end
	end
end


local function RequestRefresh()
	if not ns.InGarrison() then return end
	C_Garrison.RequestLandingPageShipmentInfo()
end


function dataobj:Scan(...)
	if not ns.dbpc[self.name.."-enabled"] then
		self.player = nil
		return
	end

	local buildings = C_Garrison.GetBuildings(LE_GARRISON_TYPE_6_0)
	for i,building in pairs(buildings) do
		if Test(self, building) then
			local _, name, _, icon = C_Garrison.GetBuildingInfo(building.buildingID)
			local _, _, _, numready, total, started = C_Garrison.GetLandingPageShipmentInfo(building.buildingID)

			if numready == total then
				self["building"..building.buildingID] = ns.IconLine(icon, name)
			else
				local timeleft = (total - numready) * 4 - (time() - started) /60/60
				local title = string.format("%s (%dhr)", name, timeleft)
				self["building"..building.buildingID] = ns.IconLine(icon, title)
			end
		else
			self["building"..building.buildingID] = nil
		end
	end
end


ae.RegisterEvent(dataobj, "GARRISON_LANDINGPAGE_SHIPMENTS", "Scan")
ae.RegisterEvent("Cork"..name, "ZONE_CHANGED", RequestRefresh)
ae.RegisterEvent("Cork"..name, "BAG_UPDATE_DELAYED", RequestRefresh)
ae.RegisterEvent("Cork"..name, "SHIPMENT_CRAFTER_INFO", RequestRefresh)
