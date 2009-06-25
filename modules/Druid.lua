
local _, c = UnitClass("player")
if c ~= "DRUID" then return end


-- Mark of the Wild
local multispell, spellname, _, icon = GetSpellInfo(21849), GetSpellInfo(1126)
Cork:GenerateRaidBuffer(spellname, multispell, icon)


-- Shapeshifts
local bear = GetSpellInfo(GetSpellInfo(5487)) and 5487 or 9634
local dobj, ref = Cork:GenerateAdvancedSelfBuffer("Fursuit", {bear, 768, 24858, 33891})
function dobj:CorkIt(frame)
	ref()
	local spell = Cork.dbpc["Fursuit-spell"]
	if self.player and Corkboard:NumLines() == 1 then return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", "player") end
end

-- Thorns
local spellname, _, icon = GetSpellInfo(467)
Cork:GenerateLastBuffedBuffer(spellname, icon)
