
local Cork = Cork
local SpellCastableOnUnit = Cork.SpellCastableOnUnit
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local _, myclass = UnitClass("player")
local IconLine = Cork.IconLine("Interface\\Icons\\INV_Glyph_Major"..myclass, "Empty glyph slots")
local defaults = Cork.defaultspc
defaults["Glyphs-enabled"] = true

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork Glyphs", {type = "cork"})

local function Test()
	if not Cork.dbpc["Glyphs-enabled"]  then return end
	local talents = GetActiveTalentGroup()
	for i=1,6 do
		local enabled, _, spellID = GetGlyphSocketInfo(i, talents)
		if enabled and not spellID then return IconLine end
	end
end

function dataobj:Scan() dataobj.player = Test() end

ae.RegisterEvent("Cork Glyphs", "GLYPH_ADDED", dataobj.Scan)
ae.RegisterEvent("Cork Glyphs", "GLYPH_REMOVED", dataobj.Scan)
ae.RegisterEvent("Cork Glyphs", "GLYPH_UPDATED", dataobj.Scan)
ae.RegisterEvent("Cork Glyphs", "USE_GLYPH", dataobj.Scan)
ae.RegisterEvent("Cork Glyphs", "PLAYER_LEVEL_UP", dataobj.Scan)
