
local pt = PeriodicTableEmbed:GetInstance("1")
local tablet = AceLibrary("Tablet-2.0")
local core = FuBar_CorkFu

local loc = {
	nicename = "Minipet",
	stone = "Hearthstone",
	astral = "Astral Recall",
	teleport = "Teleport"
}
local icon, needpet, state = "Interface\\Icons\\Ability_Seal", true


local minipet = core:NewModule(loc.nicename)
minipet.target = "Self"


---------------------------
--      Ace Methods      --
---------------------------

function minipet:OnEnable()
	self:RegisterEvent("UNIT_FLAGS")
	self:RegisterEvent("CONFIRM_SUMMON")
	self:RegisterEvent("SPELLCAST_START")
	self:RegisterEvent("SPELLCAST_FAILED")
	self:RegisterEvent("SPELLCAST_INTERRUPTED", "SPELLCAST_FAILED")
	self:RegisterEvent("PLAYER_CONTROL_GAINED", "ActivateIfState")
	self:RegisterEvent("SPELLCAST_STOP", "ActivateIfState")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ActivatePet")
	self:RegisterEvent("PLAYER_UNGHOST", "ActivatePet")
end


----------------------------
--      Cork Methods      --
----------------------------

function minipet:ItemValid()
	return true
end


function minipet:GetIcon(unit)
	return icon
end


function minipet:PutACorkInIt()
	print("Minipet", needpet, self.db.profile.player)
	if not needpet or self.db.profile.player == -1 then return end

	local petbags, petslots = {}, {}
	for bag,slot in pt:BagIter("minipetall") do
		table.insert(petbags, bag)
		table.insert(petslots, slot)
	end

	if not next(petbags) then return end

	local ridx = math.random(1, table.getn(petbags))
	UseContainerItem(petbags[ridx], petslots[ridx])
	needpet = nil
	self:TriggerEvent("CorkFu_Update")
	return true
end


function minipet:GetTopItem()
	if not needpet or self.db.profile.player == -1 then return end
	return icon, loc.nicename
end


function minipet:OnTooltipUpdate()
	if not needpet or self.db.profile.player == -1 then return end

	local cat = tablet:AddCategory("hideBlankLine", true)
	cat:AddLine("text", loc.nicename, "hasCheck", true, "checked", true, "checkIcon", icon,
		"func", self.PutACorkInIt, "arg1", self)
end


------------------------------
--      Event Handlers      --
------------------------------

function minipet:CONFIRM_SUMMON()
	state = true
end


function minipet:UNIT_FLAGS()
	if UnitOnTaxi("player") then state = true end
end


function minipet:SPELLCAST_START(spell)
	if spell and (spell == loc.stone or spell == loc.astral
	or string.find(spell, loc.teleport)) then
		state = true
	else state = nil end
end


function minipet:SPELLCAST_FAILED(spell)
	if spell and (spell == loc.stone or spell == loc.astral
	or string.find(spell, loc.teleport)) then
		state = nil
	end
end


function minipet:ActivateIfState()
	if state then self:ActivatePet() end
end


------------------------------
--      Helper Methods      --
------------------------------

function minipet:ActivatePet()
	if not pt:GetBest("minipetall") then return end
	state = nil
	needpet = true
	self:TriggerEvent("CorkFu_Update")
end





