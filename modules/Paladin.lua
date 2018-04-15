
local myname, Cork = ...
if Cork.MYCLASS ~= "PALADIN" then return end



-- Righteous Fury
local spellname, _, icon = GetSpellInfo(25780)
Cork:GenerateSelfBuffer(spellname, icon)


-- Beacon of Light
local spellname, _, icon = GetSpellInfo(53563)
local dataobj = Cork:GenerateLastBuffedBuffer(spellname, icon)
dataobj.partyonly = true
dataobj.ignoreplayer = true
