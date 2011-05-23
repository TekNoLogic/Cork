
local myname, Cork = ...


-- Items only available at 80
if UnitLevel("player") < 80 then return end


-- Drums of Forgotten Kings
Cork:GenerateItemBuffer({PALADIN = true, DRUID = true}, 49633, 69378, 20217)


-- Runescroll of Fortitude
Cork:GenerateItemBuffer("PRIEST", UnitLevel("player") < 85 and 49632 or 62251, 69377, 48161)


-- Only available to alchys
local itemname = GetItemInfo(58149) or "Flask of Enhancement"
local dataobj = Cork:GenerateSelfBuffer(itemname, GetItemIcon(58149), GetSpellInfo(79638), GetSpellInfo(79639), (GetSpellInfo(79640)))
dataobj.tiplink = "item:58149"

function dataobj:Init() Cork.defaultspc[itemname.."-enabled"] = GetItemCount(58149) > 0 end

function dataobj:CorkIt(frame)
	if self.player then return frame:SetManyAttributes("type1", "item", "item1", "item:58149") end
end
