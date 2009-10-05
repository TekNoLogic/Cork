
-- Items only available at 80
if UnitLevel("player") < 80 then return end

-- Drums of the Wild
Cork:GenerateItemBuffer("DRUID", 49634, 69381, 1126)

-- Drums of Forgotten Kings
Cork:GenerateItemBuffer("PALADIN", 49633, 69378, 20217)

-- Runescroll of Fortitude
Cork:GenerateItemBuffer("PRIEST", 49632, 69377, 48161)
