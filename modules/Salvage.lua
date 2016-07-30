
local myname, ns = ...


local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

if UnitLevel("player") < 90 then return end


local dataobj    = ns:New("Salvage")
dataobj.tiptext  = "Notify you when you have openable salvage containers and are in your garrison"
dataobj.corktype = "item"
dataobj.priority = 10


function dataobj:Init()
	ns.defaultspc[self.name.."-enabled"] = UnitLevel("player") >= 90
end


local openable_ids = {
	[118473] = true, -- Small Sack of Salvaged Goods
	[114116] = true, -- Bag of Salvaged Goods
	[114119] = true, -- Crate of Salvage
	[114120] = true, -- Big Crate of Salvage
	[139593] = true, -- Sack of Salvaged Goods
	[140590] = true, -- Large Crate of Salvage
}

local function Test()
	if not ns.InGarrison() then return end
	for id in pairs(openable_ids) do
		if GetItemCount(id) > 0 then return id end
	end
end


function dataobj:Scan()
	if not ns.dbpc[self.name.."-enabled"] then
		self.player = nil
		return
	end

	local id = Test()
	if id then
		local num = GetItemCount(id)
		local itemname, _, _, _, _, _, _, _, _, texture = GetItemInfo(id)
		if itemname then
			self.player = ns.IconLine(texture, itemname.. " (".. num.. ")")
		else
			self.player = nil
		end
	else
		self.player = nil
	end
end

ae.RegisterEvent(dataobj, "BAG_UPDATE_DELAYED", "Scan")
ae.RegisterEvent(dataobj, "GARRISON_UPDATE", "Scan")


function dataobj:CorkIt(frame)
	local id = Test()
	if id then
		return frame:SetManyAttributes("type1", "item", "item1", "item:"..id)
	end
end
