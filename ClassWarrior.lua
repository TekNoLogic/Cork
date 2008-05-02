local _, c = UnitClass("player")
if c ~= "WARRIOR" then return end

local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")

i = core:NewModule("Shout", buffs)
i.target = "Friendly"
i.defaultspell = GetSpellInfo(6673) -- Battle Shout
i.spells = {
	[i.defaultspell] = true,
	[GetSpellInfo(469)] = true, -- Commanding Shout
}
