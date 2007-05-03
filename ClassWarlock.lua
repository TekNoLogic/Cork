local _, c = UnitClass("player")
if c ~= "WARLOCK" then return end

local B = AceLibrary("Babble-Spell-2.2")
local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")

i = core:NewModule(B["Demon Armor"], buffs)
i.target = "Self"
i.defaultspell = B["Demon Armor"]
i.spells = {
	[B["Demon Armor"]] = true,
	[B["Demon Skin"]] = true,
    [B["Fel Armor"]] = true,
}

i = core:NewModule(B["Detect Invisibility"], buffs)
i.target = "Friendly"
i.spell = B["Detect Invisibility"]

i = core:NewModule(B["Unending Breath"], buffs)
i.target = "Friendly"
i.spell = B["Unending Breath"]

