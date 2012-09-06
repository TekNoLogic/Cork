
local myname, Cork = ...
if Cork.MYCLASS ~= "PRIEST" then return end


-- Fort
local spellname, _, icon = GetSpellInfo(21562)
Cork:GenerateRaidBuffer(spellname, icon)


-- Shadow Protection
local spellname, _, icon = GetSpellInfo(27683)
Cork:GenerateRaidBuffer(spellname, icon)


-- Inner Fire / Will
local spellname, _, icon = GetSpellInfo(588)
Cork:GenerateAdvancedSelfBuffer(spellname, {588,73413})


-- Shadowform
local spellname, _, icon = GetSpellInfo(15473)
Cork:GenerateSelfBuffer(spellname, icon)


-- Fear Ward
local spellname, _, icon = GetSpellInfo(6346)
Cork:GenerateLastBuffedBuffer(spellname, icon)

