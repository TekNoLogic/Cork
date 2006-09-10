
local _, c = UnitClass("player")
if c ~= "SHAMAN" then return end

local B = AceLibrary("Babble-Spell-2.0")
local core, i = FuBar_CorkFu
local buffs, debuffs = core:GetTemplate("Buffs"), core:GetTemplate("Debuffs")


i = core:NewModule(B"Lightning Shield", buffs)
i.spell = B"Lightning Shield"
i.target = "Self"


i = core:NewModule(B"Cure Poison", debuffs)
i.debufftype = "Poison"
i.spell = B"Cure Poison"
i.target = "Friendly"


i = core:NewModule(B"Cure Disease", debuffs)
i.debufftype = "Disease"
i.spell = B"Cure Disease"
i.target = "Friendly"
