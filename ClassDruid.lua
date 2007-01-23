
local _, c = UnitClass("player")
if c ~= "DRUID" then return end

local B = AceLibrary("Babble-Spell-2.2")
local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


i = core:NewModule(B["Mark of the Wild"], buffs)
i.target = "Friendly"
i.spell = B["Mark of the Wild"]
i.multispell = B["Gift of the Wild"]


i = core:NewModule(B["Thorns"], buffs)
i.target = "Friendly"
i.spell = B["Thorns"]


i = core:NewModule(B["Omen of Clarity"], buffs)
i.spell = B["Omen of Clarity"]
i.target = "Self"

