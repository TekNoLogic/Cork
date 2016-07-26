
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


local function Init(self)
	self.name = GetItemInfo(self.itemid)
	self.spellname = self.name
	self.spells = {self.name}
	self.iconline  = ns.IconLine(GetItemIcon(self.itemid), self.name)
	local itemID, name, texture, collected = C_ToyBox.GetToyInfo(self.itemid)
	self.toyname = name
	ns.defaultspc[self.name.."-enabled"] = collected or (GetItemCount(self.itemid) > 0)
end


local function CorkIt(self, frame)
	if self.player then
		local item = self.toyname or ("item:".. self.itemid)
		return frame:SetManyAttributes("type1", "item", "item1", item)
	end
end


function ns:GenerateItemSelfBuffer(itemid, buffid)
	local itemname = GetItemInfo(itemid) or ("Unknown item #".. itemid)
	local icon = GetItemIcon(itemid)
	local buff = buffid and GetSpellInfo(buffid) or itemname

	local dataobj = ns:GenerateSelfBuffer(itemname, icon, buff)
	dataobj.tiplink = "item:".. itemid
	dataobj.corktype = "item"
	dataobj.itemid = itemid
	dataobj.Init = Init
	dataobj.CorkIt = CorkIt

	return dataobj
end
