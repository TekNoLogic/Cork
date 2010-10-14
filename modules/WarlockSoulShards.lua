
local myname, Cork = ...
if Cork.MYCLASS ~= "WARLOCK" then return end


local spellname = GetSpellInfo(79268)
local IconLine = Cork.IconLine(GetItemIcon(6265), SOUL_SHARDS)
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

Cork.defaultspc[SOUL_SHARDS.. "-enabled"] = true

local dataobj = ldb:NewDataObject("Cork ".. SOUL_SHARDS, {type = "cork", tiptext = "Warn when you do not have 3 ".. SOUL_SHARDS.. " out of combat."})

function dataobj:Scan()
	if not Cork.dbpc[SOUL_SHARDS.. "-enabled"] or (IsResting() and not Cork.db.debug) or UnitPower("player", SPELL_POWER_SOUL_SHARDS) == 3 then
		dataobj.player = nil
		return
	end

	dataobj.player = IconLine
end

local function unit_power(event, unit, powertype)
	if unit == "player" and powertype == "SOUL_SHARDS" then dataobj:Scan() end
end

ae.RegisterEvent("Cork ".. SOUL_SHARDS, "UNIT_POWER", unit_power)
ae.RegisterEvent("Cork ".. SOUL_SHARDS, "PLAYER_UPDATE_RESTING", dataobj.Scan)

function dataobj:CorkIt(frame)
	if dataobj.player then return frame:SetManyAttributes("type1", "spell", "spell", spellname) end
end
