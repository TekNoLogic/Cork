local _, c = UnitClass("player")
if c ~= "PALADIN" then
	return
end

local Cork = Cork
local UnitAura = Cork.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local spellname, _, icon = GetSpellInfo(32223)
local iconline = Cork.IconLine(icon, spellname)

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {type = "cork"})

-- -1 => restore original aura
-- 0 => do nothing
-- 1 => cast crusader aura
local crusaderstate = 0
local updatefrequency = 1.0
local updatecounter = 0

local f = CreateFrame("Frame")
f:Hide()

function dataobj:Init()
	Cork.defaultspc[spellname.."-enabled"] = GetSpellInfo(spellname) ~= nil
end

-- look up the name of the spell currently selected in the Aura module
local function GetStandardAura()
	return Cork.dbpc['Aura-spell'] or spellname
end

local function Test()
	if not Cork.dbpc[spellname.."-enabled"] then
		f:Hide()
		return
	end

	crusaderstate = 0

	local haveAura = UnitAura("player", spellname)
	local isMounted = ((IsMounted() or IsUsingVehicleControls()) and not UnitOnTaxi("player"))

	if isMounted and not haveAura then
		crusaderstate = 1
		f:Show()
		return iconline
	elseif haveAura and not isMounted then
		crusaderstate = -1
		local standardAura = GetStandardAura()
		f:Show()
		return Cork.IconLine(select(3, GetSpellInfo(standardAura)), standardAura)
	else
		f:Show()
	end
end

-- reset counter to  zero to (re)start OnUpdate checking
f:SetScript("OnShow", function()
	updatecounter = 0
end)

-- call logic to check player state and trigger Cork reminder if applicable
f:SetScript("OnHide", function()
	updatecounter = updatefrequency
	dataobj.player = Test()
end)

-- trigger OnHide once per second
-- note that Hide() also suspends OnUpdate calls until Show() is called again
f:SetScript("OnUpdate", function(self, elap)
	updatecounter = updatecounter + elap
	if updatecounter >= updatefrequency then
		self:Hide()
	end
end)

function dataobj:Scan()
	self.player = Test()
end
--[[
local function EventUpdate(event, unit)
	if unit == "player" then
		dataobj:Scan()
	end
end

ae.RegisterEvent("Cork "..spellname, "UNIT_AURA", EventUpdate)
]]
function dataobj:CorkIt(frame)
	if self.player then
		if crusaderstate == -1 then
			return frame:SetManyAttributes("type1", "spell", "spell", GetStandardAura())
		elseif crusaderstate == 1 then
			return frame:SetManyAttributes("type1", "spell", "spell", spellname)
		end
	end
end
