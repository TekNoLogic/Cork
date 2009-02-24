
local _, c = UnitClass("player")
if c ~= "SHAMAN" then return end


-- Self-shields
Cork:GenerateAdvancedSelfBuffer("Shields", {324, 24398, 974})


-- Earth Shield
local spellname, _, icon = GetSpellInfo(974)
Cork:GenerateLastBuffedBuffer(spellname, icon)


--~ local wb = GetSpellInfo(131) -- Water Breathing
--~ i = core:NewModule(wb, buffs)
--~ i.target = "Friendly"
--~ i.spell = wb


--~ local ww = GetSpellInfo(546) -- Water Walking
--~ i = core:NewModule(ww, buffs)
--~ i.target = "Friendly"
--~ i.spell = ww

