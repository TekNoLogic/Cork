
if IS_WRATH_BUILD then return end

function Cork.UnitAura(unit, auraname)
	for i=1,BUFF_MAX_DISPLAY do
		local name, rank, icon, count, duration, timeLeft = UnitBuff(unit, i)
		if auraname == name then return name, nil, nil, nil, nil, nil, nil, timeLeft end
	end
end
