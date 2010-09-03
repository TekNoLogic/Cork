
local myname, Cork = ...
Cork.IHASCAT = select(4, GetBuildInfo()) >= 40000
local _, c = UnitClass("player")
if c ~= "DRUID" then return end


-- Mark of the Wild
local multispell, spellname, _, icon = GetSpellInfo(21849), GetSpellInfo(1126)
Cork:GenerateRaidBuffer(spellname, multispell, icon)


-- Shapeshifts
local forms
if Cork.IHASCAT then forms = {768, 5487, 24858} else forms = {5487, 9634, 768, 24858, 33891} end
local dobj, ref = Cork:GenerateAdvancedSelfBuffer("Fursuit", forms)
function dobj:CorkIt(frame)
	ref()
	local spell = Cork.dbpc["Fursuit-spell"]
	if self.player and Corkboard:NumLines() == 1 then return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", "player") end
end


-- Thorns
local spellname, _, icon = GetSpellInfo(467)
Cork:GenerateLastBuffedBuffer(spellname, icon)
