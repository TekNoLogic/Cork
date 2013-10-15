
local myname, Cork = ...
if Cork.MYCLASS ~= "WARLOCK" then return end

local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local spellname, _, icon = GetSpellInfo(108503)
local iconline = IconLine(icon, spellname)

local dataobj = ldb:NewDataObject("Cork Grimoire of Sacrifice", {type = "cork"})

local function IsGoSEnabled()
	return select(5, GetTalentInfo(15))
end

function dataobj:Init()
	Cork.defaultspc["Grimoire of Sacrifice-enabled"] = IsGoSEnabled()
end

local function Test()
	if not IsMounted() and Cork.dbpc["Grimoire of Sacrifice-enabled"] and IsGoSEnabled() and UnitExists("pet") and not UnitIsDead("pet") and not UnitAura("player", spellname) then
		return iconline
	end
end

function dataobj:Scan()
	dataobj.player = Test()
end

function dataobj:CorkIt(frame)
	if self.player then
		return frame:SetManyAttributes("type1", "spell", "spell", spellname)
	end
end

ae.RegisterEvent("Cork "..spellname, "UNIT_PET", function(event, unit) if unit == "player" then dataobj.player = Test() end end)
ae.RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit) if unit == "player" then dataobj.player = Test() end end)
