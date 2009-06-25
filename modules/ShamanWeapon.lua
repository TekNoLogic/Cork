
local _, c = UnitClass("player")
if c ~= "SHAMAN" then return end


local Cork = Cork
local UnitAura = Cork.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
local f, elapsed = CreateFrame("Frame"), 0
local enchantable_offhands = {INVTYPE_WEAPON = true, }


local MAINHAND, OFFHAND = GetInventorySlotInfo("MainHandSlot"), GetInventorySlotInfo("SecondaryHandSlot")
local IconLine = Cork.IconLine
local rbname, _, rbicon = GetSpellInfo(8017)
local flname, _, flicon = GetSpellInfo(8024)
local frname, _, fricon = GetSpellInfo(8033)
local wfname, _, wficon = GetSpellInfo(8232)
local elname, _, elicon = GetSpellInfo(51730)


local dataobj = ldb:NewDataObject("Cork Temp Enchant", {type = "cork"})

function dataobj:Init() Cork.defaultspc["Temp Enchant-enabled"] = true end
function dataobj:Scan() if Cork.dbpc["Temp Enchant-enabled"] then f:Show() else f:Hide(); dataobj.mainhand, dataobj.offhand = nil end end


f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < 0.5 then return end

	elapsed = 0

	local main, _, _, offhand = GetWeaponEnchantInfo()
	dataobj.mainhand = not main and GetInventoryItemLink("player", MAINHAND) and IconLine(rbicon, INVTYPE_WEAPONMAINHAND)

	local offlink = GetInventoryItemLink("player", OFFHAND)
	local offweapon = offlink and select(9, GetItemInfo(offlink)) == "INVTYPE_WEAPON"
	dataobj.offhand = not offhand and offweapon and IconLine(rbicon, INVTYPE_WEAPONOFFHAND)
end)
