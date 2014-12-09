
local myname, Cork = ...
local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local dataobj = ldb:NewDataObject("Cork Lure", {
	type     = "cork",
	corktype = "item",
	name     = "Lure",
	tiptext  = "Remind you to use a lure when you have a fishing pole equipped.",
	priority = 8,
})
Cork.defaultspc["Lure-enabled"] = true


local lures = {
	116825, -- 200 Savage Fishing Pole  (10min duration, 20min CD)
	116826, -- 200 Draenic Fishing Pole (10min duration, 20min CD)
	118391, -- 200 Worm Supreme
	117405, -- 150 Nat's Drinking Hat
	 88710, -- 150 Nat's Hat
	 68049, -- 150 Heat-Treated Spinning Lure
	 46006, -- 100 Glow Worm
	 34861, -- 100 Sharpened Fish Hook
	  6533, -- 100 Aquadynamic Fish Attractor
	 62673, -- 100 Feathered Lure
	  7307, --  75 Flesh Eating Worm
	  6532, --  75 Bright Baubles
	 33820, --  75 Weather-Beaten Fishing Hat
	  6530, --  50 Nightcrawlers
	  6811, --  50 Aquadynamic Fish Lens
	  6529, --  25 Shiny Bauble
	 67404, --  15 Glass Fishing Bobber
}
local function Test(id)
	if not Cork.dbpc[dataobj.name.."-enabled"] then return end
	if not IsEquippedItemType("Fishing Pole") then return end
	if GetWeaponEnchantInfo() then return end

	for _,id in ipairs(lures) do
		if GetItemCount(id) > 0 then return id end
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
