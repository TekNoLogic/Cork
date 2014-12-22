
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a lvl3 garrison
if level < 100 then return end


local name = "Herb garden food"
local iconline = ns.IconLine("Interface\\ICONS\\INV_Misc_Food_41", name)
local foods = {}
for i=118268,118277 do foods[i] = true end


local dataobj    = ns:New(name)
dataobj.tiptext  = "Notify you when you do not have free herb garden food in your bag"
dataobj.corktype = "item"
dataobj.priority = 15


local function ScanPlots()
	local plots = C_Garrison.GetPlots()
	for i,plot in ipairs(plots) do
		local id, _, _, _, rank = C_Garrison.GetOwnedBuildingInfoAbbrev(plot.id)
		if id == 137 and rank == 3 then return true end
	end
	return false
end


local hastree = false
local function HasTree()
	if not hastree then hastree = ScanPlots() end
	return hastree
end


local function Init(self)
	Cork.defaultspc[name.."-enabled"] = true
end


local function Test(self)
	if not C_Garrison.IsOnGarrisonMap() or not HasTree() then return end

	for id in pairs(foods) do
		if GetItemCount(id) > 0 then return end
	end

	return true
end


function dataobj:Scan()
	if ns.dbpc[self.name.."-enabled"] and Test() then
		self.player = iconline
	else
		self.player = nil
	end
end


ae.RegisterEvent(dataobj, "ZONE_CHANGED", "Scan")
ae.RegisterEvent(dataobj, "BAG_UPDATE_DELAYED", "Scan")
ae.RegisterEvent(dataobj, "GARRISON_UPDATE", "Scan")
