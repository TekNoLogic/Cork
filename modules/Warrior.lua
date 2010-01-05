
local myname, Cork = ...
local _, c = UnitClass("player")
if c ~= "WARRIOR" then return end


-- Vigilance
local spellname, _, icon = GetSpellInfo(59665)
Cork:GenerateLastBuffedBuffer(spellname, icon)
