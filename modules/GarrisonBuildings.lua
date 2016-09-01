
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a garrison
if level < 90 then return end


local name = "Completed buildings"


local dataobj    = ns:New(name)
dataobj.tiptext  = "Notify you when you are in your garrison and have a completed building"
dataobj.priority = 20
ns.defaultspc[name.."-enabled"] = level >= 100


local function Test(self, building)
	if not ns.InGarrison() then return end

	local items = C_Garrison.GetLandingPageItems(LE_GARRISON_TYPE_6_0)
	for i,item in ipairs(items) do
		if item.isComplete and item.isBuilding then return true end
	end
end


local textures = setmetatable({}, {
	__index = function(t,i)
		local buildings = C_Garrison.GetBuildings(LE_GARRISON_TYPE_6_0)
		for _,building in pairs(buildings) do
			local _, name, _, icon = C_Garrison.GetBuildingInfo(building.buildingID)
			if i == name then
				t[i] = icon
				return icon
			end
		end
	end
})


local set_indexes = {}
function dataobj:Scan(event, ...)
	for i in pairs(set_indexes) do self["index"..i] = nil end
	wipe(set_indexes)

	if not ns.dbpc[self.name.."-enabled"] or not ns.InGarrison() then return end

	local items = C_Garrison.GetLandingPageItems(LE_GARRISON_TYPE_6_0)
	for i,item in ipairs(items) do
		if item.isComplete and item.isBuilding then
			set_indexes[i] = true
			self["index"..i] = ns.IconLine(textures[item.name], item.name)
		end
	end
end


ae.RegisterEvent(dataobj, "ZONE_CHANGED", "Scan")
ae.RegisterEvent(dataobj, "GARRISON_MISSION_NPC_CLOSED", "Scan")
ae.RegisterEvent(dataobj, "GARRISON_MISSION_FINISHED", "Scan")
ae.RegisterEvent(dataobj, "GARRISON_MISSION_LIST_UPDATE", "Scan")

