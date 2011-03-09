
local myname, Cork = ...
if Cork.MYCLASS ~= "ROGUE" then return end



local spellids, poisonranklist = {3408, 2823, 8679, 5761, 13219}, {
	["Crippling Poison"] = { 3775 },
	["Deadly Poison"] = { 2892, 2893, 8984, 8985, 20844, 22053, 22054, 43232, 43233 },
	["Instant Poison"] = { 6947, 6949, 6950, 8926, 8927, 8928, 21927, 43230, 43231 },
	["Mind-numbing Poison"] = { 5237 },
	["Wound Poison"] = { 10918, 10920, 10921, 10922, 22055, 43234, 43235 },
}
Cork:GenerateTempEnchant(INVTYPE_WEAPONMAINHAND, 10, spellids, poisonranklist)
Cork:GenerateTempEnchant(INVTYPE_WEAPONOFFHAND, 10, spellids, poisonranklist)
Cork:GenerateTempEnchant(INVTYPE_THROWN, 10, spellids, poisonranklist)
