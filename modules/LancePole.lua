
local myname, Cork = ...
local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local slot = GetInventorySlotInfo("MainHandSlot")
local lances, poles, ITEMS = {46069, 46106, 46070}, {6256, 6365, 6366, 6367, 12225, 19022, 25978, 45858, 45992, 45991, 19970, 44050}, {}
for _,id in pairs(poles) do ITEMS[id] = "pole" end
for _,id in pairs(lances) do ITEMS[id] = true end

Cork.defaultspc["Lances and Poles-enabled"] = true

local dataobj = ldb:NewDataObject("Cork Lances and Poles", {type = "cork"})

local incombat
function dataobj:Scan()
	if self == "PLAYER_REGEN_DISABLED" then incombat = true
	elseif self == "PLAYER_REGEN_ENABLED" then incombat = false end

	local id = GetInventoryItemID("player", 16)

	if not Cork.dbpc["Lances and Poles-enabled"] or not ITEMS[id] or ITEMS[id] == "pole" and not incombat then
		dataobj.player = nil
		return
	end

	dataobj.player = IconLine(GetItemIcon(id), (GetItemInfo(id)))
end

ae.RegisterEvent("Cork Lance", "UNIT_INVENTORY_CHANGED", dataobj.Scan)
ae.RegisterEvent("Cork Lance", "PLAYER_REGEN_DISABLED", dataobj.Scan)
ae.RegisterEvent("Cork Lance", "PLAYER_REGEN_ENABLED", dataobj.Scan)
