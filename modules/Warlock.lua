
local myname, Cork = ...
if Cork.MYCLASS ~= "WARLOCK" then return end


-- Demon Armor
local spellname = GetSpellInfo(687)
Cork:GenerateAdvancedSelfBuffer(spellname, {687, 28176})


-- Dark Intent
local spellname, _, icon = GetSpellInfo(109773)
Cork:GenerateRaidBuffer(spellname, icon)


--~ local di = GetSpellInfo(132) -- Detect Invisibility
--~ i = core:NewModule(di, buffs)
--~ i.target = "Friendly"
--~ i.spell = di


--~ local ueb = GetSpellInfo(5697) -- Unending Breath
--~ i = core:NewModule(ueb, buffs)
--~ i.target = "Friendly"
--~ i.spell = ueb

