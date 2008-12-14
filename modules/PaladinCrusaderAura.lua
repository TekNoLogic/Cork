
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end


local Cork = Cork
local UnitAura = Cork.UnitAura or UnitAura

local spellname, _, icon = GetSpellInfo(32223)
local iconline = Cork.IconLine(icon, spellname)
local mounted = false

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {type = "cork"})


function dataobj:Init()
	Cork.defaultspc[spellname.."-enabled"] = GetSpellInfo(spellname) ~= nil
end


local function Test()
	if not Cork.dbpc[spellname.."-enabled"] then return end

	local crusading = UnitAura("player", spellname)

	if mounted and not crusading then return iconline
	elseif crusading and not mounted then
		local aura = Cork.dbpc['Aura-spell'] or spellname
		return Cork.IconLine(select(3, GetSpellInfo(aura)), aura)
	end
end


local elapsed = 0
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < 0.5 then return end

	elapsed = 0
	if not mounted == not ((IsMounted() or IsUsingVehicleControls()) and not UnitOnTaxi("player")) then return end

	mounted = not mounted
	dataobj.player = Test()
end)


function dataobj:Scan() self.player = Test() end
LibStub("AceEvent-3.0").RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit) if unit == "player" then dataobj.player = Test() end end)


function dataobj:CorkIt(frame)
	if not self.player then return end
	if self.player == iconline then return frame:SetManyAttributes("type1", "spell", "spell", spellname)
	else return frame:SetManyAttributes("type1", "spell", "spell", Cork.dbpc['Aura-spell'] or spellname) end
end
