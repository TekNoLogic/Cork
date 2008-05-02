
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end

local core, i = FuBar_CorkFu
local buffs = core:GetTemplate("Buffs")


local pwf = GetSpellInfo(1243) -- Power Word: Fortitude
i = core:NewModule(pwf, buffs)
i.target = "Friendly"
i.spell = pwf
i.multispell = GetSpellInfo(21562) -- Prayer of Fortitude


local tow = GetSpellInfo(2652) -- Touch of Weakness
i = core:NewModule(tow, buffs)
i.target = "Self"
i.spell = tow


local ifire = GetSpellInfo(588) -- Inner Fire
i = core:NewModule(ifire, buffs)
i.spell = ifire
i.target = "Self"


local fw = GetSpellInfo(6346) -- Fear Ward
i = core:NewModule(fw, buffs)
i.spell = fw
i.target = "Friendly"


local ds = GetSpellInfo(14752) -- Divine Spirit
i = core:NewModule(ds, buffs)
i.target = "Friendly"
i.spell = ds
i.multispell = GetSpellInfo(27681) -- Prayer of Spirit


local sp = GetSpellInfo(976) -- Shadow Protection
i = core:NewModule(sp, buffs)
i.target = "Friendly"
i.spell = sp
i.multispell = GetSpellInfo(27683) -- Prayer of Shadow Protection


local sf = GetSpellInfo(15473) -- Shadow Form
i = core:NewModule(sf, buffs)
i.target = "Self"
i.spell = sf
