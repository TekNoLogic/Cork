
local myname, Cork = ...
local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local ITEMS = {
	[33567] = 5,
	[34056] = 3,
	[52718] = 3,
	[52720] = 3,
	[52977] = 5,
	[74252] = 3,
	[89112] = 10,
	[90407] = 10,
	[115502] = 10,
	[115504] = 10,

	[110610] = 10,
	[108391] = 10,
	[109991] = 10,
	[109992] = 10,

	[111589] = 20,
	[111662] = 20,
	[118564] = 20,
	[111595] = 10,
	[118565] = 10,
	[111601] = 5,
	[118566] = 5,

	[118592] = 2,
	[119094] = 2,
	[119095] = 2,
	[119096] = 2,
	[119097] = 2,
	[119098] = 2,
	[119099] = 2,
	[119100] = 2,
	[119101] = 2,
	[119102] = 2,
	[119185] = 4,
}

for i=37700,37705 do ITEMS[i] = 10 end   -- crystallized elements
for i=97619,97624 do ITEMS[i] = 10 end   -- panda herbs
for i=108318,108365 do ITEMS[i] = 10 end -- herbalism
for i=109624,109629 do ITEMS[i] = 10 end -- draenor herbs
for i=108294,108309 do ITEMS[i] = 10 end -- mining
for i=111650,111659 do ITEMS[i] = 20 end -- small draenor fish
for i=111663,111669 do ITEMS[i] = 10 end -- medium draenor fish
for i=111670,111676 do ITEMS[i] = 5 end  -- large draenor fish


Cork.defaultspc["Combine-enabled"] = true

local dataobj = ldb:NewDataObject("Cork Combine", {
	type = "cork",
	corktype = "item",
	tiptext = "Warn when you have items in your bags that can be condensed like essences and crystalized elements.",
})

function dataobj:Scan()
	if not Cork.dbpc["Combine-enabled"] or InCombatLockdown() then
		dataobj.player = nil
		return
	end

	for id,threshold in pairs(ITEMS) do
		local count = GetItemCount(id) or 0
		if count >= threshold then
			local itemName, _, _, _, _, _, _, _, _, itemTexture = GetItemInfo(id)
			if itemName then
				dataobj.player = IconLine(itemTexture, itemName.." ("..count..")")
				return
			end
		end
	end
	dataobj.player = nil
end

ae.RegisterEvent("Cork Combine", "BAG_UPDATE", dataobj.Scan)

function dataobj:CorkIt(frame)
	if dataobj.player then
		for id,threshold in pairs(ITEMS) do
			if (GetItemCount(id) or 0) >= threshold then
				return frame:SetManyAttributes("type1", "item", "item1", "item:"..id)
			end
		end
	end
end
