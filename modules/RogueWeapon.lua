
local myname, Cork = ...
if Cork.MYCLASS ~= "ROGUE" then return end



local spellids, poisonranklist = {3408, 2823, 8679, 5761, 13219}, {
	["Crippling Poison"] = { 3775 },
	["Deadly Poison"] = { 2892 },
	["Instant Poison"] = { 6947 },
	["Mind-numbing Poison"] = { 5237 },
	["Wound Poison"] = { 10918 },
}
Cork:GenerateTempEnchant(INVTYPE_WEAPONMAINHAND, spellids, 10, poisonranklist)
Cork:GenerateTempEnchant(INVTYPE_WEAPONOFFHAND, spellids, 10, poisonranklist)
Cork:GenerateTempEnchant(INVTYPE_THROWN, spellids, 10, poisonranklist)
