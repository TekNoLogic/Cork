
local myname, Cork = ...
if Cork.MYCLASS ~= "DRUID" then return end


-- Shapeshifts
local dobj, ref = Cork:GenerateAdvancedSelfBuffer("Fursuit", {768, 5487, 24858})
function dobj:CorkIt(frame)
	ref()
	local spell = Cork.dbpc["Fursuit-spell"]
	if self.player and Corkboard:NumLines() == 1 then
		return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", "player")
	end
end
