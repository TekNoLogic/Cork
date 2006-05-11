
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end

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
	if not SpecialEvents:RegisterModule("SpecialEventsAura", self) then
		self.cmd:error("Cannot register with SpecialEventsAura")
	end

	self:TriggerEvent("CORKFU_REGISTER_MODULE", self)
end


function CorkFu_PWFort:Enable()
	self:TestUnit("player")
	for i=1,GetNumPartyMembers() do self:TestUnit("party"..i) end
	for i=1,GetNumRaidMembers() do self:TestUnit("raid"..i) end

	self:RegisterEvent("SPECIAL_UNIT_BUFF_LOST")
	self:RegisterEvent("SPECIAL_UNIT_BUFF_GAINED")
	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_PWFort:Disable()
	self:UnregisterAllEvents()
end


function CorkFu_PWFort:TestUnit(unit)
	if not UnitExists(unit) then return end
	local sb = SpecialEventsAura:UnitHasBuff(unit, self.loc.buff)
	local mb = SpecialEventsAura:UnitHasBuff(unit, self.loc.multibuff)
	self.tagged[unit] = sb or mb or 42
end


function CorkFu_PWFort:SPECIAL_UNIT_BUFF_GAINED(unit, buff)
	self.tagged[unit] = buff
	self:TriggerEvent("CORKFU_UPDATE")
end


function CorkFu_PWFort:SPECIAL_UNIT_BUFF_LOST(unit, buff)
	if buff ~= self.loc.buff then return end

	if self.tagged[unit] == buff then
		self.tagged[unit] = 42
		self:TriggerEvent("CORKFU_UPDATE")
	end
end


--------------------------------
--      Load this bitch!      --
--------------------------------
CorkFu_PWFort:RegisterForLoad()
