
local _, c = UnitClass("player")
if c ~= "HUNTER" then return end

local tektech = TekTechEmbed:GetInstance("1")
local seaura = SpecialEventsEmbed:GetInstance("Aura 1")
local tablet = AceLibrary("Tablet-2.0")

local feedpet = "Feed Pet"
local icon = "Interface\\Icons\\Ability_Hunter_BeastTraining"
local core, happyness = FuBar_CorkFu

local happy = core:NewModule("Pet Happiness")
happy.target = "Self"


---------------------------
--      Ace Methods      --
---------------------------

function happy:OnEnable()
	self:UNIT_HAPPINESS()
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_HAPPINESS")
	self:TriggerEvent("CorkFu_Update")

	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_LOST")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_GAINED")
end


function happy:OnDisable()
	seaura:UnregisterAllEvents(self)
end


----------------------------
--      Cork Methods      --
----------------------------

function happy:ItemValid()
	return tektech:SpellKnown(feedpet)
end


function happy:UnitValid(unit)
	return unit == "pet" and UnitExists(unit) and not UnitIsDeadOrGhost(unit)
end


function happy:GetIcon()
	return icon
end


function happy:PutACorkInIt()
	if FOM_Feed then
		FOM_Feed()
		return true
	end
end


function happy:OnTooltipUpdate()
	if not self:ItemValid() or happyness ~= true or not self:UnitValid("pet") or self.db.profile.player == -1 then return end

	local cat = tablet:AddCategory("hideBlankLine", true)
	cat:AddLine("text", UnitName("pet").." is hungry", "hasCheck", true, "checked", true, "checkIcon", icon,
		"func", self.PutACorkInIt, "arg1", self)
end


function happy:GetTopItem()
	if not self:ItemValid() or happyness ~= true or not self:UnitValid("pet") or core:UnitIsFiltered(self, "pet") then return end

	return icon, UnitName("pet")
end


------------------------------
--      Event Handlers      --
------------------------------

function happy:UNIT_HAPPINESS()
	if seaura:UnitHasBuff("pet", "Feed Pet Effect") then return end

	local h = GetPetHappiness()
	happyness = h ~= 3
	self:TriggerEvent("CorkFu_Update")
end


function happy:UNIT_PET()
	if arg1 == "player" then self:UNIT_HAPPINESS() end
end


function happy:SPECIAL_UNIT_BUFF_GAINED(unit, buff)
	if unit == "pet" and buff == "Feed Pet Effect" then
		happyness = "Feeding"
		self:TriggerEvent("CorkFu_Update")
	end
end


function happy:SPECIAL_UNIT_BUFF_LOST(unit, buff)
	if unit == "pet" and buff == "Feed Pet Effect" then self:UNIT_HAPPINESS() end
end



