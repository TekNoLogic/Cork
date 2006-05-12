
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end

local seaura = SpecialEventsEmbed:GetInstance("Aura 1")

CorkFu_PWFort = AceAddon:new({
	name          = "CorkFu_PWFort",
	cmd           = AceChatCmd:new({}, {}),

	loc = {
		buff = "Power Word: Fortitude",
		multibuff = "Prayer of Fortitude",
		spell = "Power Word: Fortitude",
	},
	k = {
		icon = "Spell_Holy_WordFortitude",
		usenormalcasting = true,
		scalerank = true,
		ranklevels = {1,12,24,36,48,60},
	},
	tagged = {},
})


function CorkFu_PWFort:Initialize()
	self:TriggerEvent("CORKFU_REGISTER_MODULE", self)
end


function CorkFu_PWFort:Enable()
	self:TestUnit("player")
	for i=1,GetNumPartyMembers() do self:TestUnit("party"..i) end
	for i=1,GetNumRaidMembers() do self:TestUnit("raid"..i) end

	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_LOST")
	seaura:RegisterEvent(self, "SPECIAL_UNIT_BUFF_GAINED")
	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_PWFort:Disable()
	self:UnregisterAllEvents()
end


function CorkFu_PWFort:TestUnit(unit)
	if not UnitExists(unit) then return end
	local sb = seaura:UnitHasBuff(unit, self.loc.buff)
	local mb = seaura:UnitHasBuff(unit, self.loc.multibuff)
	self.tagged[unit] = sb or mb or true
end


function CorkFu_PWFort:SPECIAL_UNIT_BUFF_GAINED(unit, buff)
	if (buff ~= self.loc.buff and buff ~= self.loc.multibuff) then return end

	self.tagged[unit] = buff
	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_PWFort:SPECIAL_UNIT_BUFF_LOST(unit, buff)
	if (buff ~= self.loc.buff and buff ~= self.loc.multibuff) then return end

	if self.tagged[unit] == buff then
		self.tagged[unit] = true
		self:TriggerEvent("CORKFU_UPDATE")
	end
end


--------------------------------
--      Load this bitch!      --
--------------------------------
CorkFu_PWFort:RegisterForLoad()
