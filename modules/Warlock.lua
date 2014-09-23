
local myname, Cork = ...
if Cork.MYCLASS ~= "WARLOCK" then return end


-- Dark Intent
local FORT, CSHOUT = GetSpellInfo(21562), GetSpellInfo(469)
local ARCB, BWRATH = GetSpellInfo(1459), GetSpellInfo(77747)
local spellname, _, icon = GetSpellInfo(109773)
Cork:GenerateRaidBuffer(spellname, icon, nil, nil, function(unit)
	if UnitAura(unit, spellname) then return true end
	if (UnitAura(unit, FORT) or UnitAura(unit, CSHOUT)) -- Another stamina buff
		and (UnitAura(unit, ARCB) or UnitAura(unit, BWRATH) or UnitPowerType(unit) ~= SPELL_POWER_MANA) -- Another spellpower buff (or not a mana user)
	then
		return true
	end
end)


-- Soulstone
local spellname, _, icon = GetSpellInfo(20707)
local dataobj = Cork:GenerateLastBuffedBuffer(spellname, icon)

local wasgrouped
local oldGRU = dataobj.GROUP_ROSTER_UPDATE
function dataobj:GROUP_ROSTER_UPDATE(...)
	local nowgrouped = IsInGroup()
	if wasgrouped and not nowgrouped then
		dataobj.onlyrebuffs = false
		dataobj.lasttarget = nil
	elseif not wasgrouped and nowgrouped then
		dataobj.onlyrebuffs = true
		dataobj.lasttarget = nil
	end

	wasgrouped = nowgrouped

	return oldGRU(self, ...)
end
