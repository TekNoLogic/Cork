
local _, c = UnitClass("player")
if c ~= "SHAMAN" then return end


-- Shields
Cork:GenerateAdvancedSelfBuffer("Shields", {324, 24398, 974})


--~ local es = GetSpellInfo(974) -- Earth Shield
--~ i = core:NewModule(es, buffs)
--~ i.target = "Friendly"
--~ i.spell = es


--~ local wb = GetSpellInfo(131) -- Water Breathing
--~ i = core:NewModule(wb, buffs)
--~ i.target = "Friendly"
--~ i.spell = wb


--~ local ww = GetSpellInfo(546) -- Water Walking
--~ i = core:NewModule(ww, buffs)
--~ i.target = "Friendly"
--~ i.spell = ww

