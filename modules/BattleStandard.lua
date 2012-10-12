
local myname, Cork = ...


local ally = UnitFactionGroup('player') == "Alliance"
local ids = ally and {64399, 64398, 63359} or {64402, 64401, 64400}
local buffname = GetSpellInfo(90633)


local dataobj = Cork:GenerateSelfBuffer(buffname, GetItemIcon(ids[1]))
dataobj.tiplink = "item:"..ids[1]
dataobj.lowpriority = true


local function FindItem()
	for _,id in ipairs(ids) do
		if GetItemCount(id) > 0 then return id end
	end
end


function dataobj:Init()
	Cork.defaultspc[buffname.."-enabled"] = FindItem() ~= nil
end


function dataobj:CorkIt(frame)
	local itemowned = FindItem()
	if self.player and itemowned then
		return frame:SetManyAttributes("type1", "item", "item1", "item:"..itemowned)
	end
end
