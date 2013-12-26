
local myname, ns = ...


local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local dataobj    = ns:New("Openable items")
dataobj.tiptext  = "Notify you when there are openable containers in your bags"
dataobj.corktype = "item"
dataobj.priority = 8


function dataobj:Init()
	ns.defaultspc[self.name.."-enabled"] = true
end


local openable_ids = {}
local function IsOpenable(bag, slot, id)
	if openable_ids[id] ~= nil then return openable_ids[id] end

	ns.scantip:SetBagItem(bag, slot)
	for i=1,5 do
		if ns.scantip.L[i] == ITEM_OPENABLE then
			openable_ids[id] = true
			return true
		end
	end
	openable_ids[id] = false
	return false
end


local function Test()
	for bag=0,4 do
		for slot=1,GetContainerNumSlots(bag) do
			local itemid = GetContainerItemID(bag, slot)
			if itemid and IsOpenable(bag, slot, itemid) then return itemid end
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
		self.player = ns.IconLine(texture, itemname.. " (".. num.. ")")
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
