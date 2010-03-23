
local _, c = UnitClass("player")
if c ~= "WARLOCK" then return end

local myname, Cork = ...
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local ITEMS = {5232, 16892, 16893, 16895, 16896, 22116, 36895}
local spellname, _, icon = GetSpellInfo(693)
local buffName = GetSpellInfo(20707)
local iconline = Cork.IconLine(icon, "Soulstone")

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork Soulstone", {type = "cork", tiplink = GetSpellLink(spellname)})


function dataobj:Init()
	Cork.defaultspc["Soulstone-enabled"] = not not GetSpellInfo(spellname)
end


local f = CreateFrame("Frame")
local nexttime = 0
function dataobj:Scan()
	if not Cork.dbpc["Soulstone-enabled"] or IsResting() then
		f:Hide()
		dataobj.custom = nil
		return
	end

	local start, duration = GetItemCooldown("item:5232")
	nexttime = start + duration
	local _, _, _, _, _, _, buffNextTime = UnitBuff("player", buffName)
	if type(buffNextTime) == "number" and buffNextTime > nexttime then 
		nexttime = buffNextTime
	end
	if nexttime == 0 then
		f:Hide()
		dataobj.custom = iconline
	else f:Show() end
end

f:SetScript("OnShow", function() dataobj.custom = nil end)
f:SetScript("OnHide", function() dataobj.custom = iconline end)
f:SetScript("OnUpdate", function(self) if GetTime() >= nexttime then self:Hide() end end)

ae.RegisterEvent("Cork Soulstone", "BAG_UPDATE", dataobj.Scan)
ae.RegisterEvent("Cork Soulstone", "PLAYER_UPDATE_RESTING", dataobj.Scan)
ae.RegisterEvent("Cork Soulstone", "UNIT_AURA", function(event, unit) if unit == "player" then return dataobj.Scan() end end)

function dataobj:CorkIt(frame)
	if not dataobj.custom then return end
	for _,id in pairs(ITEMS) do if (GetItemCount(id) or 0) > 0 then return frame:SetManyAttributes("type1", "item", "item1", "item:"..id) end end
	return frame:SetManyAttributes("type1", "spell", "spell", spellname)
end
