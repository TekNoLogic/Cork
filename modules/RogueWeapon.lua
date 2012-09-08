
local myname, Cork = ...
if Cork.MYCLASS ~= "ROGUE" then return end

-- Damage poisons
Cork:GenerateAdvancedSelfBuffer("Poison - Damage", {2823,8679})

-- Utility poisons
Cork:GenerateAdvancedSelfBuffer("Poison - Utility", {3408,5761,108211,108215})
