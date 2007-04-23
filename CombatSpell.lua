
local core = FuBar_CorkFu
local dewdrop = AceLibrary("Dewdrop-2.0")

local loc = {
	nicename = "Combat Spell",
}


local combat = core:NewModule(loc.nicename, "AceDebug-2.0")
combat.debugFrame = ChatFrame5
combat.target = "Self"
--~ combat.uncorkable = true
combat.defaultDB = {spell = ""}


---------------------------
--      Ace Methods      --
---------------------------

function combat:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
end


----------------------------
--      Cork Methods      --
----------------------------

function combat:ItemValid()
	return true
end


function combat:GetIcon(unit)
end


function combat:PutACorkInIt()
end


function combat:GetTopItem()
end


function combat:OnTooltipUpdate()
end


function combat:SetFilter(value)
	self.db.profile.spell = value
	return value
end


function combat:RootMenuItem()
	dewdrop:AddLine("text", self:ToString() or "No name???", "hasArrow", true,
		"hasEditBox", true, "editBoxText", self.db.profile.spell,
		"editBoxChangeFunc", self.SetFilter, "editBoxChangeArg1", self)
end


------------------------------
--      Event Handlers      --
------------------------------

function combat:PLAYER_REGEN_DISABLED()
	core.secureframe:SetManyAttributes("type1", "spell", "spell1", self.db.profile.spell)
end


function combat:PLAYER_REGEN_ENABLED()
	core.secureframe:SetAttribute("type1", ATTRIBUTE_NOOP)
end

