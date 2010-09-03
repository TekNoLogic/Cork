
local myname, Cork = ...
if Cork.MYCLASS ~= "DRUID" then return end


if Cork.IHASCAT then
	-- Mark of the Wild
	local spellname, _, icon = GetSpellInfo(1126)
	Cork:GenerateRaidBuffer(spellname, icon)


	-- Shapeshifts
	local dobj, ref = Cork:GenerateAdvancedSelfBuffer("Fursuit", {768, 5487, 24858})
	function dobj:CorkIt(frame)
		ref()
		local spell = Cork.dbpc["Fursuit-spell"]
		if self.player and Corkboard:NumLines() == 1 then return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", "player") end
	end
else
	-- Mark of the Wild
	local multispell, spellname, _, icon = GetSpellInfo(21849), GetSpellInfo(1126)
	Cork:GenerateRaidBuffer(spellname, multispell, icon)


	-- Shapeshifts
	local dobj, ref = Cork:GenerateAdvancedSelfBuffer("Fursuit", {5487, 9634, 768, 24858, 33891})
	function dobj:CorkIt(frame)
		ref()
		local spell = Cork.dbpc["Fursuit-spell"]
		if self.player and Corkboard:NumLines() == 1 then return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", "player") end
	end
end


-- Thorns
local spellname, _, icon = GetSpellInfo(467)
Cork:GenerateLastBuffedBuffer(spellname, icon)
