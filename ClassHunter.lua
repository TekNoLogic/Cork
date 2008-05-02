
local _, c = UnitClass("player")
if c ~= "HUNTER" then return end

local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


local tsa = GetSpellInfo(19506) -- Trueshot Aura
i = core:NewModule(tsa, buffs)
i.spell = tsa
i.target = "Self"


i = core:NewModule("Aspects", buffs)
i.target = "Self"
i.canstack = true
i.defaultspell = GetSpellInfo(13165) -- Aspect of the Hawk
i.spells = {
	[i.defaultspell]      = true, -- Aspect of the Hawk
	[GetSpellInfo(13161)] = true, -- Aspect of the Beast
	[GetSpellInfo(13163)] = true, -- Aspect of the Monkey
	[GetSpellInfo(5118)]  = true, -- Aspect of the Cheetah
	[GetSpellInfo(13159)] = true, -- Aspect of the Pack
	[GetSpellInfo(20043)] = true, -- Aspect of the Wild
	[GetSpellInfo(34074)] = true, -- Aspect of the Viper
}

