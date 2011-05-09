
local myname, Cork = ...

-- Items only available at 80
if UnitLevel("player") < 80 then return end

-- Drums of Forgotten Kings
Cork:GenerateItemBuffer({PALADIN = true, DRUID = true}, 49633, 69378, 20217)

-- Runescroll of Fortitude
Cork:GenerateItemBuffer("PRIEST", UnitLevel("player") < 85 and 49632 or 62251, 69377, 48161)
