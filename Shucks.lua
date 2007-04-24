
local pt = PeriodicTableEmbed:GetInstance("1")
local tablet = AceLibrary("Tablet-2.0")
local core = FuBar_CorkFu

local loc = {
	nicename = "Shuck Clams",
}
local items = {7973, 24476, 5523, 15874, 5524}
local lastcount, needsupdate = 0
local icon = "Interface\\Icons\\INV_Misc_Shell_03"


local shuck = core:NewModule(loc.nicename, "AceDebug-2.0")
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
	if not self:ItemValid() or lastconut == 0 or self.db.profile["Filter Everyone"] == -1 then return end
	self:Debug("Shucking a clam")

	for _,id in pairs(items) do
		if GetItemCount(id) then
			local name = GetItemInfo(id)
			core.secureframe:SetManyAttributes("type1", "item", "item1", "Small Barnacled Clam")
			return true
		end
	end
end


function shuck:GetTopItem()
	if not self:ItemValid() or self.db.profile["Filter Everyone"] == -1 then return end
	return icon, loc.nicename.." - ".. lastcount
end


function shuck:OnTooltipUpdate()
	if not self:ItemValid() or self.db.profile["Filter Everyone"] == -1 then return end
	self:Debug("Updating tablet")

	local cat = tablet:AddCategory("hideBlankLine", true)
	cat:AddLine("text", loc.nicename.." - ".. lastcount, "hasCheck", true, "checked", true, "checkIcon", icon,
		"func", self.PutACorkInIt, "arg1", self)
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

