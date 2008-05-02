
local _, c = UnitClass("player")
if c ~= "SHAMAN" then return end

local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


local es = GetSpellInfo(974) -- Earth Shield
i = core:NewModule(es, buffs)
i.target = "Friendly"
i.spell = es


local ls = GetSpellInfo(324) -- Lightning Shield
i = core:NewModule(ls, buffs)
i.spell = ls
i.target = "Self"


local ws = GetSpellInfo(24398) -- Water Shield
i = core:NewModule(ws, buffs)
i.spell = ws
i.target = "Self"


local wb = GetSpellInfo(131) -- Water Breathing
i = core:NewModule(wb, buffs)
i.target = "Friendly"
i.spell = wb


local ww = GetSpellInfo(546) -- Water Walking
i = core:NewModule(ww, buffs)
i.target = "Friendly"
i.spell = ww

