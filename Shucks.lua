
local core = FuBar_CorkFu

local loc = {
	nicename = "Shuck Clams",
}
local items = {7973, 24476, 5523, 15874, 5524, 32724}
local lastcount, needsupdate = 0
local icon = "Interface\\Icons\\INV_Misc_Shell_03"


local shuck = core:NewModule(loc.nicename)
shuck.debugFrame = ChatFrame5
shuck.target = "Self"


---------------------------
--      Ace Methods      --
---------------------------

function shuck:OnEnable()
	self:BAG_UPDATE()
	self:RegisterEvent("BAG_UPDATE")
end


----------------------------
--      Cork Methods      --
----------------------------

function shuck:ItemValid()
	if lastcount > 0 then return true end
end


function shuck:GetIcon(unit)
	return icon
end


function shuck:PutACorkInIt()
	if not self:ItemValid() or self.db.profile["Filter Everyone"] == -1 then return end

	for _,id in pairs(items) do
		if (GetItemCount(id) or 0) > 0 then
			local name = GetItemInfo(id)
			self:Debug("Shucking a clam:", name)
			core.secureframe:SetManyAttributes("type1", "item", "item1", name)
			return true
		end
	end
end


function shuck:GetTopItem()
	if not self:ItemValid() or self.db.profile["Filter Everyone"] == -1 then return end
	return icon, loc.nicename.." - ".. lastcount
end


function shuck:OnTooltipUpdate(tooltip)
	if not self:ItemValid() or self.db.profile["Filter Everyone"] == -1 then return end
	tooltip:AddIconLine(icon, loc.nicename.." - ".. lastcount)
end


------------------------------
--      Event Handlers      --
------------------------------

function shuck:BAG_UPDATE()
	local count = 0
	for _,id in pairs(items) do
		count = count + (GetItemCount(id) or 0)
	end

	if count ~= lastcount then
		lastcount = count or 0
		self:TriggerEvent("CorkFu_Update")
	end
end

