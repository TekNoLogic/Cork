
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end


local spellname, _, icon = GetSpellInfo(588)
local iconline = IconLine(icon, UnitName("player"))
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine
local thresh = 2


local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
local dataobj = ldb:NewDataObject("Cork_InnerFire", {type = "cork"})


local function Test(unit) if not UnitAura("player", spellname) then return iconline end end
ae.RegisterEvent("Cork_InnerFire", "UNIT_AURA", function(event, unit) if unit == "player" then dataobj.player = Test() end end)
dataobj.player = Test()


function dataobj:CorkIt(frame)
	if dataobj.player then
		frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", unit)
		return true
	end
end
