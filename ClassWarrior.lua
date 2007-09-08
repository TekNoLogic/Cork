local _, c = UnitClass("player")
if c ~= "WARRIOR" then return end

local B = AceLibrary("Babble-Spell-2.2")
local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")

i = core:NewModule(B["Battle Shout"], buffs)
i.target = "Friendly"
i.defaultspell = B["Battle Shout"]
i.spells = {
	[B["Battle Shout"]] = true,
	[B["Commanding Shout"]] = true,
}