
local myname, Cork = ...
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local ICON, ITEMS = "Interface\\Icons\\INV_Crate_05", {6351, 6352, 6353, 6355, 6356, 6357, 13874, 13875, 20708, 21113, 21150, 21228, 27513, 27446, 27481, 34863, 35348, 44475, 46007, 67597, 68798, 68799, 68800, 68801, 68801, 68803, 68804, 68805, 78930, 88496}

Cork.defaultspc["Crates-enabled"] = true

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork Crates", {type = "cork", tiptext = "Warn when you have fished-up crates that need opened."})

function dataobj:Scan()
	if not Cork.dbpc["Crates-enabled"] then
		dataobj.player = nil
		return
	end

	local count = 0
	for _,id in pairs(ITEMS) do count = count + (GetItemCount(id) or 0) end

	if count > 0 then dataobj.player = IconLine(ICON, "Crates ("..count..")")
	else dataobj.player = nil end
end

ae.RegisterEvent("Cork Crates", "BAG_UPDATE", dataobj.Scan)

function dataobj:CorkIt(frame)
	for _,id in pairs(ITEMS) do
		if (GetItemCount(id) or 0) > 0 then return frame:SetManyAttributes("type1", "item", "item1", "item:"..id) end
	end
end
