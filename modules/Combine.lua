
local Cork = Cork
local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local MODULE = "Combine"
local ITEMS = {
	[37700] = 10, -- Crystallized Air
	[37701] = 10, -- Crystallized Earth
	[37702] = 10, -- Crystallized Fire
	[37703] = 10, -- Crystallized Shadow
	[37704] = 10, -- Crystallized Life
	[37705] = 10, -- Crystallized Water
	[33567] = 5,  -- Borean Leather Scraps
	[34056] = 3,  -- Lesser Cosmic Essence
}

Cork.defaultspc[MODULE.."-enabled"] = true

local dataobj = ldb:NewDataObject("Cork "..MODULE, {type = "cork"})

function dataobj:Scan()
	if Cork.dbpc[MODULE.."-enabled"] and not InCombatLockdown() then
		for id,threshold in pairs(ITEMS) do
			local count = GetItemCount(id) or 0
			if count >= threshold then
				local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(id) 
				dataobj.player = IconLine(itemTexture, itemName.." ("..count..")")
				return
			end
		end
	end
	dataobj.player = nil
end

ae.RegisterEvent("Cork "..MODULE, "BAG_UPDATE", dataobj.Scan)

function dataobj:CorkIt(frame)
	if dataobj.player then
		for id,threshold in pairs(ITEMS) do
			if (GetItemCount(id) or 0) >= threshold then 
				dataobj.player = nil
				return frame:SetManyAttributes("type1", "item", "item1", "item:"..id) 
			end
		end
	end
end
