-- Hack repairs into talents

local Cork = Cork
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local ICON = "Interface\\Minimap\\Tracking\\Repair"
local defaults = Cork.defaultspc
defaults["Talents-enabled"] = true

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork Talents", {type = "cork"})

local function Test()
	if not Cork.dbpc["Talents-enabled"] or not IsResting() then return end

	local points = UnitCharacterPoints("player")

	if points < 1 then return end
	return IconLine(ICON, "You have " ..  points .. " unspent Talent Points.")
end

function dataobj:Scan() dataobj.player = Test() end

ae.RegisterEvent("Cork Talents", "CHARACTER_POINTS_CHANGED", dataobj.Scan)
ae.RegisterEvent("Cork Talents", "PLAYER_UPDATE_RESTING", dataobj.Scan)
