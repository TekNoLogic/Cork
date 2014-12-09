
local myname, Cork = ...
local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local dataobj = ldb:NewDataObject("Cork Fishing hat", {
	type     = "cork",
	corktype = "item",
	name     = "Fishing hat",
	tiptext  = "Remind you to equip your fishing hat when you have a fishing pole equipped.",
	priority = 7,
})
Cork.defaultspc["Fishing hat-enabled"] = true


local hats = {
	118393, -- 100 Tentacled Hat
	118380, -- 100 Hightfish Cap
	117405, --  10 Nat's Drinking Hat
	 88710, --   5 Nat's Hat
	 93732, --   5 Darkmoon Fishing Cap
	 33820, --   5 Weather-Beaten Fishing Hat
	 19972, --   5 Lucky Fishing Hat
}
local function Test(id)
	if not Cork.dbpc[dataobj.name.."-enabled"] then return end
	if not IsEquippedItemType("Fishing Pole") then return end

	for _,id in ipairs(hats) do
		if GetItemCount(id) > 0 then
			return (not IsEquippedItem(id)) and id
		end
	end
end


function dataobj:Scan(event, unit)
	if unit ~= "player" then return end

	local id = Test()
	if id then
		self.player = IconLine(GetItemIcon(id), (GetItemInfo(id)))
	else
		self.player = nil
	end
end


function dataobj:CorkIt(frame)
	local id = Test()
	if id then
		return frame:SetManyAttributes("type1", "item", "item1", "item:"..id)
	end
end


ae.RegisterEvent(dataobj, "UNIT_INVENTORY_CHANGED", "Scan")
