
local myname, Cork = ...
if Cork.MYCLASS ~= "PALADIN" then return end


-- Righteous Fury
local spellname, _, icon = GetSpellInfo(25780)
Cork:GenerateSelfBuffer(spellname, icon)


-- Greater Blessing of Might
local spellname, _, icon = GetSpellInfo(203528)
Cork:GenerateSelfBuffer(spellname, icon)


-- Greater Blessing of Kings
local spellname, _, icon = GetSpellInfo(203538)
Cork:GenerateSelfBuffer(spellname, icon)


-- Greater Blessing of Wisdom
local spellname, _, icon = GetSpellInfo(203539)
Cork:GenerateSelfBuffer(spellname, icon)


-- Beacon of Light
local spellname, _, icon = GetSpellInfo(53563)
local dataobj = Cork:GenerateLastBuffedBuffer(spellname, icon)
dataobj.partyonly = true
dataobj.ignoreplayer = true
