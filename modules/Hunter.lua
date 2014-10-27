
local myname, Cork = ...
if Cork.MYCLASS ~= "HUNTER" then return end


-- Aspects
Cork:GenerateAdvancedSelfBuffer("Aspects", {5118, 13159, 61648})

-- Exotic Munitions
local _, _, _, selected, _ = GetTalentInfo(7,1,GetActiveSpecGroup())
if selected then
	Cork:GenerateAdvancedSelfBuffer("Exotic Munitions", {162536, 162537, 162539})
end

--	Trap launcher
Cork:GenerateAdvancedSelfBuffer("Trap Launcher", {77769})
