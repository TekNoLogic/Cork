
local dewdrop = AceLibrary("Dewdrop-2.0")

local core, mybuff = FuBar_CorkFu, -1
local spells, defaultspell = {}


local track = core:NewModule("Tracking")
track.target = "Custom"


function track:OnEnable()
	for i=1,GetNumTrackingTypes() do
		local name, texture, active, category = GetTrackingInfo(i)
		spells[name] = texture
		if active then defaultspell = name end
	end
	if not defaultspell then defaultspell = next(spells) end

	self:RegisterEvent("CorkFu_Rescan")
	self:RegisterEvent("PLAYER_AURAS_CHANGED")
	self:PLAYER_AURAS_CHANGED()
end


----------------------------
--      Cork Methods      --
----------------------------

function track:ItemValid()
	return true
end


function track:UnitValid(unit)
	return unit == "player"
end


function track:GetIcon()
	local filter = self.db.char["Filter Everyone"]
	return filter and spells[filter] or defaultspell and spells[defaultspell]
end


function track:GetTopItem()
	if not self:ItemValid() or mybuff or self.db.char["Filter Everyone"] == -1 then return end

	local spell = self.db.char["Filter Everyone"] or defaultspell
	return spells[spell], spell
end


function track:PutACorkInIt()
	local _, spell = self:GetTopItem()
	if not spell then return end
	core.secureframe:SetManyAttributes("type1", "spell", "spell", spell)
	return true
end


function track:OnTooltipUpdate(tooltip)
	if not self:ItemValid() or mybuff or self.db.char["Filter Everyone"] == -1 then return end

	local spell = self.db.char["Filter Everyone"] or defaultspell
	tooltip:AddLine(spells[spell], spell)
end


function track:OnMenuRequest()
	local val = self.db.char["Filter Everyone"] or defaultspell

	dewdrop:AddLine("text", core.loc.disabled, "func", self.SetFilter, "isRadio", true, "checked", val == -1, "arg1", self,
		"arg2", "Everyone", "arg3", -1, "arg4", "char")
	for v in pairs(spells) do
		dewdrop:AddLine("text", v, "func", self.SetFilter, "isRadio", true, "checked", val == v,
			"arg1", self, "arg2", "Everyone", "arg3", v, "arg4", "char")
	end
end


------------------------------
--      Event Handlers      --
------------------------------


function track:CorkFu_Rescan(spell)
	if spells[spell] or spell == "All" then self:PLAYER_AURAS_CHANGED() end
end


function track:PLAYER_AURAS_CHANGED()
	local x = GetTrackingTexture()
	if x == mybuff then return end

	mybuff = x
	self:TriggerEvent("CorkFu_Update")
end


