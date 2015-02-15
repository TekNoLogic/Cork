
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a garrison
if level < 90 then return end


local name = "Garrison cache"


local dataobj    = ns:New(name)
dataobj.tiptext  = "Notify you when you are in your garrison and the resource cache is unopened"
dataobj.priority = 20
ns.defaultspc[name.."-enabled"] = true


local function SecondsSinceLastOpened()
	local lasttime = ns.dbpc[name.."-lastopen"] or 0
	return time() - lasttime
end


local function Test()
	if not C_Garrison.IsOnGarrisonMap() then return end
	return SecondsSinceLastOpened() > (60*60*16)
end


function dataobj:Scan()
	if ns.dbpc[self.name.."-enabled"] and Test() then
		local size = SecondsSinceLastOpened() / 60 / 10
		if not ns.dbpc[name.."-lastopen"] then
			self.player = ns.IconLine("Interface\\ICONS\\inv_garrison_resource", name)
			return
		end

		if size > 500 then size = 500 end
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
