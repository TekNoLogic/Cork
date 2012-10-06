
local myname, Cork = ...
if Cork.MYCLASS ~= "MONK" then return end


-- Stance
Cork:GenerateAdvancedSelfBuffer("Stance", {103985, 115069, 115070}, false, true)

-- Legacy of the Emperor
local spellname, _, icon = GetSpellInfo(115921)
local KINGS, MARK = GetSpellInfo(20217), GetSpellInfo(1126)
Cork:GenerateRaidBuffer(spellname, icon, nil, nil, function(unit)
	return UnitAura(unit, KINGS) or UnitAura(unit, MARK)
end)