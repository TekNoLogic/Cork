
local myname, ns = ...
local empoweringlocals = {
	["Empowering"] = true,
	["Stärkungszauber"] = true,
	["Mejora"] = true,
	["Buff"] = true,
	["Beneficio"] = true,
	["Bônus"] = true,
	["Аура"] = true,
	}


local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local dataobj    = ns:New("Artifact Power Items")
dataobj.tiptext  = "Notify you when there are items with artifact power in your bags"
dataobj.corktype = "item"
dataobj.priority = 8


function dataobj:Init()
	ns.defaultspc[self.name.."-enabled"] = true
end



local function Test()
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			local itemid = GetContainerItemID(bag, slot)
			if itemid and empoweringlocals[GetItemSpell(itemid)] then return itemid end
		end
	end
end


local lastid
function dataobj:Scan()
	if not ns.dbpc[self.name.."-enabled"] then
		self.player = nil
		return
	end

	lastid = Test()
	if lastid then
		local num = GetItemCount(lastid)
		local itemname, _, _, _, _, _, _, _, _, texture = GetItemInfo(lastid)
		if itemname ~= nil then
			self.player = ns.IconLine(texture, itemname.. " (".. num.. ")")
		else
			-- we probably haven't seen the item yet so it's not cached
			self.player = nil
		end
	else
		self.player = nil
	end
end

ae.RegisterEvent(dataobj, "BAG_UPDATE_DELAYED", "Scan")


function dataobj:CorkIt(frame)
	if lastid then
		return frame:SetManyAttributes("type1", "item", "item1", "item:"..lastid)
	end
end
