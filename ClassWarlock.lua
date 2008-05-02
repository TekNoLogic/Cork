local _, c = UnitClass("player")
if c ~= "WARLOCK" then return end

local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


local ds = GetSpellInfo(687) -- Demon Skin
i = core:NewModule(ds, buffs)
i.target = "Self"
i.defaultspell = ds
i.spells = {
	[GetSpellInfo(706)] = true, -- Demon Armor
	[ds] = true,
	[GetSpellInfo(28176)] = true, -- Fel Armor
}


local di = GetSpellInfo(132) -- Detect Invisibility
i = core:NewModule(di, buffs)
i.target = "Friendly"
i.spell = di


local ueb = GetSpellInfo(5697) -- Unending Breath
i = core:NewModule(ueb, buffs)
i.target = "Friendly"
i.spell = ueb

