
local Cork = Cork
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local ICON, ITEMS = "Interface\\Icons\\INV_Misc_Shell_03", {7973, 24476, 5523, 15874, 5524, 32724, 36781}

Cork.defaultspc["Shuck Clams-enabled"] = true

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork Shuck Clams", {type = "cork"})

function dataobj:Scan()
	if not Cork.dbpc["Shuck Clams-enabled"] then
		dataobj.player = nil
		return
	end

	local count = 0
	for _,id in pairs(ITEMS) do count = count + (GetItemCount(id) or 0) end

	if count > 0 then dataobj.player = IconLine(ICON, "Shuck clams ("..count..")")
	else dataobj.player = nil end
end

ae.RegisterEvent("Cork Shuck Clams", "BAG_UPDATE", dataobj.Scan)

function dataobj:CorkIt(frame)
	for _,id in pairs(ITEMS) do
		if (GetItemCount(id) or 0) > 0 then return frame:SetManyAttributes("type1", "item", "item1", "item:"..id) end
	end
end
