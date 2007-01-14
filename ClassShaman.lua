
local _, c = UnitClass("player")
if c ~= "SHAMAN" then return end

local B = AceLibrary("Babble-Spell-2.2")
local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


i = core:NewModule(B["Earth Shield"], buffs)
i.target = "Friendly"
i.spell = B["Earth Shield"]


i = core:NewModule(B["Lightning Shield"], buffs)
i.spell = B["Lightning Shield"]
i.target = "Self"


i = core:NewModule(B["Water Breathing"], buffs)
i.target = "Friendly"
i.spell = B["Water Breathing"]


i = core:NewModule(B["Water Walking"], buffs)
i.target = "Friendly"
i.spell = B["Water Walking"]

