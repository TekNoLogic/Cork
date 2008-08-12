
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


function Cork:GenerateSelfBuffer(spellname, icon)
	local iconline = self.IconLine(icon, UnitName("player"))
	local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {type = "cork"})

	local function Test(unit) if not UnitAura("player", spellname) then return iconline end end

	LibStub("AceEvent-3.0").RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit) if unit == "player" then dataobj.player = Test() end end)
	dataobj.player = Test()

	function dataobj:CorkIt(frame)
		if self.player then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "player") end
	end
end
