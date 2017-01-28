
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a garrison
if level < 90 then return end


function ns.InGarrison()
	return C_Garrison.IsOnGarrisonMap() or C_Garrison.IsOnShipyardMap()
end


local name = "Garrison cache"


local dataobj    = ns:New(name)
dataobj.tiptext  = "Notify you when you are in your garrison and the resource cache is unopened"
dataobj.priority = 20
ns.defaultspc[name.."-enabled"] = true


local function SecondsSinceLastOpened()
	local lasttime = ns.dbpc[name.."-lastopen"] or 0
	return time() - lasttime
end


local function MaxSize()
	return IsQuestFlaggedCompleted(37485) and 1000 or 500
end


local function AmountPending()
	local size = SecondsSinceLastOpened() / 60 / 10
	return math.min(size, MaxSize())
end


local function Test()
	if not ns.InGarrison() then return end
	return AmountPending() >= (MaxSize() - (24*60/10))
end


function dataobj:Scan()
	if ns.dbpc[self.name.."-enabled"] and Test() then
		if not ns.dbpc[name.."-lastopen"] then
			self.player = ns.IconLine("Interface\\ICONS\\inv_garrison_resource", name)
			return
		end

		local size = AmountPending()
		local title = string.format("%s (%d)", name, size)
		self.player = ns.IconLine("Interface\\ICONS\\inv_garrison_resource", title)
	else
		self.player = nil
	end
end


ae.RegisterEvent(dataobj, "ZONE_CHANGED", "Scan")
ae.RegisterEvent("Cork "..name, "SHOW_LOOT_TOAST", function(event, ...)
	local _, _, _, _, _, _, lootSource = ...
	if lootSource == 10 then
		ns.dbpc[name.."-lastopen"] = time()
	end

	dataobj:Scan()
end)
