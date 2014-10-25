
local myname, Cork = ...
if Cork.MYCLASS ~= "PRIEST" then return end


-- Fort
local DARKINT, spellname, _, icon = GetSpellInfo(109773), GetSpellInfo(21562)
Cork:GenerateRaidBuffer(spellname, icon, nil, nil, function(unit)
	if UnitAura(unit, DARKINT) then return true end
end)


-- Shadowform
local spellname, _, icon = GetSpellInfo(15473)
Cork:GenerateSelfBuffer(spellname, icon)


-- Fear Ward
local spellname, _, icon = GetSpellInfo(6346)
local dataobj = Cork:GenerateLastBuffedBuffer(spellname, icon)
dataobj.onlyrebuffs = true


-- Chakras
Cork:GenerateAdvancedSelfBuffer("Chakra", {81206, 81208, 81209})
