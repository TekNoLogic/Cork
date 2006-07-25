
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")
local pt = PeriodicTableEmbed:GetInstance("1")
local core = FuBar_CorkFu

local loc = {
	nicename = "Argent Dawn Commission",
	buff = "Argent Dawn Commission",
}

-- Add localized zone names directly into this table!
local zones = {
	["Western Plaguelands"] = true,
	["Eastern Plaguelands"] = true,
	["Stratholme"] = true,
	["Scholomance"] = true,
}


CorkFu_ADCommission = AceAddon:new({
	name = "CorkFu_ADCommission",
	nicename = loc.nicename,

	k = {
		buff = loc.buff,
		icon = "INV_Jewelry_Talisman_07",
		selfonly = true,
	},

	tagged = {},
})


---------------------------
--      Ace Methods      --
---------------------------

function CorkFu_ADCommission:Initialize()
	self:TriggerEvent("CORKFU_REGISTER_MODULE", self)
end


function CorkFu_ADCommission:Enable()
	self:RegisterEvent("CORKFU_RESCAN")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")

	self:ZONE_CHANGED_NEW_AREA()
end


function CorkFu_ADCommission:Disable()
	self:UnregisterAllEvents()
end


----------------------------
--      Cork Methods      --
----------------------------

function CorkFu_ADCommission:ItemValid()
	return zones[GetRealZoneText()]
end


function CorkFu_ADCommission:UnitValid(unit)
	return unit == "player"
end


function CorkFu_ADCommission:GetIcon(unit)
	return self.k.icon
end


function CorkFu_ADCommission:PutACorkInIt(unit)
	local bag, slot = pt:GetBest("argentdawncommission")
	if bag and slot then
		PickupContainerItem(bag, slot)
		AutoEquipCursorItem()
	end
end


------------------------------
--      Event Handlers      --
------------------------------

function CorkFu_ADCommission:ZONE_CHANGED_NEW_AREA()
	SetMapToCurrentZone()

	if zones[GetRealZoneText()] then
		seaura:RegisterEvent(self, "SPECIAL_PLAYER_BUFF_LOST")
		seaura:RegisterEvent(self, "SPECIAL_PLAYER_BUFF_GAINED")

		self:Scan()
	else
		seaura:UnregisterAllEvents(self)
	end

	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_ADCommission:CORKFU_RESCAN(spell)
	if spell == "All" then self:Scan() end
end


function CorkFu_ADCommission:SPECIAL_PLAYER_BUFF_GAINED(buff)
	if buff ~= self.k.buff then return end

	self.tagged.player = buff
	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_ADCommission:SPECIAL_PLAYER_BUFF_LOST(buff)
	if buff ~= self.k.buff then return end

	if self.tagged.player == buff then
		self.tagged.player = true
		self:TriggerEvent("CORKFU_UPDATE")
	end
end


------------------------------
--      Helper Methods      --
------------------------------

function CorkFu_ADCommission:Scan()
	self.tagged.player = seaura:UnitHasBuff("player", self.k.buff) or true
end


CorkFu_ADCommission:RegisterForLoad()