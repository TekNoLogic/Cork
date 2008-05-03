
local seaura = AceLibrary("SpecialEvents-Aura-2.0")
local core = FuBar_CorkFu


local template = AceLibrary("AceOO-2.0").Mixin {
	"OnEnable",
	"OnDisable",
	"ItemValid",
	"GetIcon",
	"PutACorkInIt",
	"CorkFu_Rescan",
	"SpecialEvents_UnitBuffGained",
	"SpecialEvents_UnitBuffLost",
	"OnTooltipUpdate",
	"GetTopItem",
}
core:RegisterTemplate("SimpleSelfBuff", template)


function template:OnEnable()
	self:RegisterEvent("CorkFu_Rescan")
	self:RegisterEvent("SpecialEvents_UnitBuffLost")
	self:RegisterEvent("SpecialEvents_UnitBuffGained")

	self.needbuff = not seaura:UnitHasBuff("player", self.spell)

	self:TriggerEvent("CorkFu_Update")
end


----------------------------
--      Cork Methods      --
----------------------------

function template:ItemValid()
	return GetSpellInfo(self.spell)
end


function template:GetIcon()
	return self.icon
end


function template:GetTopItem()
	if self:ItemValid() and self.needbuff and not self:UnitIsFiltered("player") then return self.icon, self.spell, "player" end
end


function template:PutACorkInIt(unit)
	core.secureframe:SetManyAttributes("type1", "spell", "spell", self.spell, "unit", "player")
	return true
end


------------------------------
--      Event Handlers      --
------------------------------


function template:CorkFu_Rescan(spell)
	if spell == self.spell or spell == "All" then self.needbuff = not seaura:UnitHasBuff("player", self.spell) end
end


function template:SpecialEvents_UnitBuffGained(unit, buff)
	if unit ~= "player" or buff ~= self.spell then return end

	self.needbuff = false
	self:TriggerEvent("CorkFu_Update")
end


function template:SpecialEvents_UnitBuffLost(unit, buff)
	if unit ~= "player" or buff ~= self.spell then return end

	self.needbuff = true
	self:TriggerEvent("CorkFu_Update")
end


------------------------------
--      Helper Methods      --
------------------------------

function template:OnTooltipUpdate(tooltip)
	if self:ItemValid() and self.needbuff and not self:UnitIsFiltered("player") then tooltip:AddIconLine(self.icon, self.spell) end
end
