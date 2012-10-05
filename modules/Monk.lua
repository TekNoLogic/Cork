
local myname, Cork = ...
if Cork.MYCLASS ~= "MONK" then return end


-- Legacy of the Emperor
local spellname, _, icon = GetSpellInfo(115921)
local MARK, KINGS = GetSpellInfo(1126), GetSpellInfo(20217)
local GRACE, MIGHT = GetSpellInfo(116956), GetSpellInfo(19740)
Cork:GenerateRaidBuffer(spellname, icon, nil, nil, function(unit)
	-- If a druid already hit this unit, we don't need to
	if UnitAura(unit, MARK) then return true end

	-- If a pally cast Kings when he should have put up Might, overwrite it
	if UnitAura(unit, KINGS) then
		-- If either mastery buff is also present, we're good and don't need to buff
		return UnitAura(unit, MIGHT) or UnitAura(unit, GRACE)
	end
end)
