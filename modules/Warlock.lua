
local myname, Cork = ...
if Cork.MYCLASS ~= "WARLOCK" then return end

-- Dark Intent
local spellname, _, icon = GetSpellInfo(80398)
Cork:GenerateLastBuffedBuffer(spellname, icon, true)


--~ local di = GetSpellInfo(132) -- Detect Invisibility
--~ i = core:NewModule(di, buffs)
--~ i.target = "Friendly"
--~ i.spell = di


--~ local ueb = GetSpellInfo(5697) -- Unending Breath
--~ i = core:NewModule(ueb, buffs)
--~ i.target = "Friendly"
--~ i.spell = ueb

