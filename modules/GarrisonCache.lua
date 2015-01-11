
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a garrison
if level < 90 then return end


local name = "Garrison cache"
local iconline = ns.IconLine("Interface\\ICONS\\inv_garrison_resource", name)


local dataobj    = ns:New(name)
dataobj.tiptext  = "Notify you when you are in your garrison and the resource cache is unopened"
dataobj.priority = 20
ns.defaultspc[name.."-enabled"] = true


local function Test(force)
	if not C_Garrison.IsOnGarrisonMap() then return end

	local lasttime = ns.dbpc[name.."-lastopen"] or 0
	return (time() - (60*60*16)) > lasttime
end


function dataobj:Scan()
	if ns.dbpc[self.name.."-enabled"] and Test() then
		self.player = iconline
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
