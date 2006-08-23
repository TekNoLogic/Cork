
local _, c = UnitClass("player")
if c ~= "HUNTER" then return end

local tektech = TekTechEmbed:GetInstance("1")
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")

local feedpet = "Feed Pet"
local icon = "Interface\\Icons\\Ability_Hunter_BeastTraining"

CorkFu_Hunter_PetHappy = AceAddon:new({
	name = "CorkFu_Hunter_PetHappy",
	nicename = "Pet Happiness",

	k = {},
	tagged = {},
})


---------------------------
--      Ace Methods      --
---------------------------

function CorkFu_Hunter_PetHappy:Initialize()
	self:TriggerEvent("CORKFU_REGISTER_MODULE", self)
end


function CorkFu_Hunter_PetHappy:Enable()
	self:UNIT_HAPPINESS()
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_HAPPINESS")
	self:TriggerEvent("CORKFU_UPDATE")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_LOST")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_GAINED")
end


function CorkFu_Hunter_PetHappy:Disable()
	self:UnregisterAllEvents()
	seaura:UnregisterAllEvents(self)
end


----------------------------
--      Cork Methods      --
----------------------------

function CorkFu_Hunter_PetHappy:ItemValid()
	return tektech:SpellKnown(feedpet)
end


function CorkFu_Hunter_PetHappy:UnitValid(unit)
	return unit == "pet" and UnitExists(unit) and not UnitIsDeadOrGhost(unit)
end


function CorkFu_Hunter_PetHappy:GetIcon()
	return icon
end


function CorkFu_Hunter_PetHappy:PutACorkInIt()
	if FOM_Feed then FOM_Feed() end
end


------------------------------
--      Event Handlers      --
------------------------------

function CorkFu_Hunter_PetHappy:UNIT_HAPPINESS()
	if seaura:UnitHasBuff("pet", "Feed Pet Effect") then return end

	local happy = GetPetHappiness()
	self.tagged.pet = happy ~= 3
	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_Hunter_PetHappy:UNIT_PET()
	if arg1 == "player" then self:UNIT_HAPPINESS() end
end


function CorkFu_Hunter_PetHappy:SPECIAL_UNIT_BUFF_GAINED(unit, buff)
	if unit == "pet" and buff == "Feed Pet Effect" then
		self.tagged.pet = "Feeding"
		self:TriggerEvent("CORKFU_UPDATE")
	end
end


function CorkFu_Hunter_PetHappy:SPECIAL_UNIT_BUFF_LOST(unit, buff)
	if unit == "pet" and buff == "Feed Pet Effect" then self:UNIT_HAPPINESS() end
end


--------------------------------
--      Load this bitch!      --
--------------------------------
CorkFu_Hunter_PetHappy:RegisterForLoad()
