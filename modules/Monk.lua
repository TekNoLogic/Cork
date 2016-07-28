
local myname, Cork = ...
if Cork.MYCLASS ~= "MONK" then return end


-- Enlightenment (EXP boost buff)
local UnitAura = Cork.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
local spellname, _, icon = GetSpellInfo(130283)
local iconline = Cork.IconLine(icon, spellname)
local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {
	type = "cork",
	tiplink = GetSpellLink(130283),
})

function dataobj:Init()
	local level = UnitLevel('player')
	Cork.defaultspc[spellname.."-enabled"] = level >= 20 and level < 90
end

local function Test(unit)
	if not Cork.dbpc[spellname.."-enabled"] then return end
	if UnitAura("player", spellname) then return end

	-- We only need to check the level 20 quest, they all return true if any one
	-- has been completed.  It's like the fishing dailies, a random one each day.
	if IsQuestFlaggedCompleted(31840) then return end

	local level = UnitLevel('player')
	if level < 20 or level >= 90 then return end

	return iconline
end

function dataobj:Scan() self.player = Test() end

ae.RegisterEvent(dataobj, "PLAYER_UPDATE_RESTING", "Scan")
ae.RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit)
	if unit == "player" then dataobj.player = Test() end
end)
