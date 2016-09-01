
local myname, Cork = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Garrison only available at 90
if level < 90 then return end


local dataobj = Cork:GenerateItemSelfBuffer(122298)
dataobj.Test = dataobj.TestWithoutResting

local function HasBodyguard()
	local buildings = C_Garrison.GetBuildings(2)
	for i,building in pairs(buildings) do
		if building.buildingID == 27 or building.buildingID == 28 then
			return not not C_Garrison.GetFollowerInfoForBuilding(building.plotID)
		end
	end
end

local orig = dataobj.Init
function dataobj:Init()
	orig(self)
	if Cork.defaultspc[self.name.."-enabled"] then
		Cork.defaultspc[self.name.."-enabled"] = HasBodyguard()
	end
	self.Init = nil
end
