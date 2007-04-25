
------------------------------
--      Are you local?      --
------------------------------

local pt, ids, set, cache = {}, {}, "12846:1,13209:2,19812:2,23206:3,23207:3"
setmetatable(ids, {__mode = "k"})
PeriodicTableMicro = pt


local function TableStuffer(...)
	local t = {}
	for i=1,select("#", ...) do
		local v = select(i, ...)
		local id,val = string.split(":", v)
		t[tonumber(id)] = tonumber(val)
	end
	return t
end


local function GetID(item)
	if item and ids[item] then return ids[item] end

	local t = type(item)
	if t == "number" then return item
	elseif t == "string" then
		local _, _, id = string.find(item, "item:(%d+):")
		if not id then return end
		ids[item] = tonumber(id)
		return ids[item]
	end
end


local function ItemInSet(item)
	local i = GetID(item)
	if not i then return end

	if not cache then
		cache = TableStuffer(string.split(" ,", set))
		TableStuffer = nil
	end
	return cache[i]
end


setmetatable(pt, {__call = function(self)
	local bval, bbag, bslot = 0
	for bag=1,4 do
		for slot=1,GetContainerNumSlots(bag) do
			local link = GetContainerItemLink(bag,slot)
			local val = link and ItemInSet(link)
			if val and val > bval then
				bval, bbag, bslot = val, bag, slot
			end
		end
	end
	return bbag, bslot
end})




