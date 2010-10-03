
local myname, Cork = ...
if Cork.MYCLASS ~= "WARLOCK" then return end


if Cork.IHASCAT then
	-- Demon Armor
	local spellname = GetSpellInfo(687)
	Cork:GenerateAdvancedSelfBuffer(spellname, {687, 28176})
else
	-- Demon Skin
	Cork:GenerateAdvancedSelfBuffer("Demon Skin", {687, 706, 28176})
end


--~ local di = GetSpellInfo(132) -- Detect Invisibility
--~ i = core:NewModule(di, buffs)
--~ i.target = "Friendly"
--~ i.spell = di


--~ local ueb = GetSpellInfo(5697) -- Unending Breath
--~ i = core:NewModule(ueb, buffs)
--~ i.target = "Friendly"
--~ i.spell = ueb

