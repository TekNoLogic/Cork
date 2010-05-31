
local _, c = UnitClass("player")
if c ~= "MAGE" then return end

local Cork = Cork
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local conjurespellname = GetSpellInfo(759)
local conjurespell = GetSpellInfo(conjurespellname)

local ICON, ITEMS = "Interface\\Icons\\INV_Misc_Gem_Sapphire_02", { 5514, 8007, 5513, 8008, 33312 }

Cork.defaultspc["Mana Gem-enabled"] = true

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork Mana Gem", {type = "cork"})

function dataobj:Scan()
	if not Cork.dbpc["Mana Gem-enabled"] then
		dataobj.player = nil
		return
	end

	local count = 0
	for _,id in pairs(ITEMS) do
		local charges = GetItemCount(id, nil, true)
		if charges == 3 then
			count = count + 1
		end
	end

	if count == 0 then dataobj.player = IconLine(ICON, "Mana Gem")
	else dataobj.player = nil end
end

ae.RegisterEvent("Cork Mana Gem", "BAG_UPDATE", dataobj.Scan)
ae.RegisterEvent("Cork Mana Gem", "BAG_UPDATE_COOLDOWN", dataobj.Scan)

function dataobj:CorkIt(frame)
	-- refresh if they just learned it
	conjurespell = conjurespell or GetSpellInfo(conjurespellname)

	if self.player then return frame:SetManyAttributes("type1", "spell", "spell", conjurespell, "unit", "player") end
end
