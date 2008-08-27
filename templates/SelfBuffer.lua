
local Cork = Cork
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


function Cork:GenerateSelfBuffer(spellname, icon)
	local _, token = UnitClass("player")
	local iconline = self.IconLine(icon, UnitName("player"), token)

	local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {type = "cork"})

	function dataobj:Init() Cork.defaultspc[spellname.."-enabled"] = GetSpellInfo(spellname) ~= nil end

	local function Test(unit) if Cork.dbpc[spellname.."-enabled"] and not UnitAura("player", spellname) then return iconline end end

	LibStub("AceEvent-3.0").RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit) if unit == "player" then dataobj.player = Test() end end)

	function dataobj:Scan() self.player = Test() end

	function dataobj:CorkIt(frame)
		if self.player then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "player") end
	end
end
