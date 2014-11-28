
local myname, Cork = ...
local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local ITEMS = {
  [37700] = 10,
  [37701] = 10,
  [37702] = 10,
  [37703] = 10,
  [37704] = 10,
  [37705] = 10,
  [33567] = 5,
  [34056] = 3,
  [52718] = 3,
  [52720] = 3,
  [52977] = 5,
  [89112] = 10,
  [90407] = 10,
  [115504] = 10,
  [115502] = 10,
  [109624] = 10,
  [109625] = 10,
  [109626] = 10,
  [109628] = 10,
  [109629] = 10,
  [110610] = 10,
  [108391] = 10,
  [109991] = 10,
  [109992] = 10,
  -- Draenor fish: small
  [111589] = 20,
  [111650] = 20,
  [111651] = 20,
  [111652] = 20,
  [111656] = 20,
  [111658] = 20,
  [111659] = 20,
  [111662] = 20,
  [118564] = 20,
  -- normal size
  [111595] = 10,
  [111663] = 10,
  [111664] = 10,
  [111665] = 10,
  [111666] = 10,
  [111667] = 10,
  [111668] = 10,
  [111669] = 10,
  [118565] = 10,
  -- enormous
  [111601] = 5,
  [111670] = 5,
  [111671] = 5,
  [111672] = 5,
  [111673] = 5,
  [111674] = 5,
  [111675] = 5,
  [111676] = 5,
  [118566] = 5,
}

for i=108318,108365 do ITEMS[i] = 10 end -- herbalism
for i=108294,108309 do ITEMS[i] = 10 end -- mining


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
