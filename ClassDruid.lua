
local _, c = UnitClass("player")
if c ~= "DRUID" then return end

local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


local motw = GetSpellInfo(1126) -- Mark of the Wild
i = core:NewModule(motw, buffs)
i.target = "Friendly"
i.spell = motw
i.multispell = GetSpellInfo(21849) -- Gift of the Wild


local th = GetSpellInfo(467) -- Thorns
i = core:NewModule(th, buffs)
i.target = "Friendly"
i.spell = th


local omen = GetSpellInfo(16864) -- Omen of Clarity
i = core:NewModule(omen, buffs)
i.spell = omen
i.target = "Self"


i = core:NewModule("Fursuit", buffs)
i.target = "Self"
i.defaultspell = GetSpellInfo(5487) -- Bear
i.spells = {
	[i.defaultspell]      = true,
	[GetSpellInfo(768)]   = true, -- Cat
	[GetSpellInfo(9634)]  = true, -- Dire Bear
	[GetSpellInfo(24858)] = true, -- Moonkin
	[GetSpellInfo(33891)] = true, -- Tree
}


