
local myname, Cork = ...
Cork.IHASCAT = select(4, GetBuildInfo()) >= 40000
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end


local myname, Cork = ...
local UnitAura = UnitAura

local spellname, _, icon = GetSpellInfo(32223)
local auras = {}
if Cork.IHASCAT then for _,id in pairs{465, 7294, 19746, 19891, 32223} do auras[GetSpellInfo(id)] = true end
else for _,id in pairs{465, 7294, 19746, 19876, 19888, 19891} do auras[GetSpellInfo(id)] = true end end
local iconline = Cork.IconLine(icon, spellname)
local mounted = false

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {type = "cork", tiplink = "spell:32223"})


function dataobj:Init()
	Cork.defaultspc[spellname.."-enabled"] = GetSpellInfo(spellname) ~= nil
end


local function Test()
	if not Cork.dbpc[spellname.."-enabled"] then return end

	local name, _, _, _, _, _, _, isMine = UnitAura("player", spellname)
	local crusading = name and isMine == "player"

	if mounted and not crusading then return iconline
	elseif crusading and not mounted and not IsResting() then
		for buff in pairs(auras) do
			local name, _, _, _, _, _, _, isMine = UnitAura("player", buff)
			if name and isMine == "player" then return end
		end

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


-- Rescan when the aura module's config changes
local AuraDO = LibStub:GetLibrary("LibDataBroker-1.1"):GetDataObjectByName("Cork Aura")
local orig = AuraDO.Scan
function AuraDO:Scan(...)
	dataobj.player = Test()
	return orig(self, ...)
end


function dataobj:Scan() self.player = Test() end
LibStub("AceEvent-3.0").RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit) if unit == "player" then dataobj.player = Test() end end)


function dataobj:CorkIt(frame)
	if not self.player then return end
	if self.player == iconline then return frame:SetManyAttributes("type1", "spell", "spell", spellname)
	else return frame:SetManyAttributes("type1", "spell", "spell", Cork.dbpc['Aura-spell'] or spellname) end
end
