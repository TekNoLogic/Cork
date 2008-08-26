
local _, c = UnitClass("player")
if c ~= "PALADIN" then return end


local Cork = Cork
local SpellCastableOnUnit = Cork.SpellCastableOnUnit
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local spellidlist = {20375, 31892, 53736, 20164, 20165, 21084, 53720, 31801}

local iconline = Cork.IconLine(select(3, GetSpellInfo(spellidlist[1])), "No seal!")
local buffnames = {}
for _,id in pairs(spellidlist) do buffnames[id] = GetSpellInfo(id) end

local defaults = Cork.defaultspc
defaults["Seal-enabled"] = true

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork Seal", {type = "cork"})

local function Test()
	if Cork.dbpc["Seal-enabled"] then
		for _,buff in pairs(buffnames) do if UnitAura("player", buff) then return end end
		return iconline
	end
end

LibStub("AceEvent-3.0").RegisterEvent("Cork Seal", "UNIT_AURA", function(event, unit) if unit == "player" and InCombatLockdown() then dataobj.player = Test() end end)
LibStub("AceEvent-3.0").RegisterEvent("Cork Seal", "PLAYER_REGEN_DISABLED", function() dataobj.player = Test() end)
LibStub("AceEvent-3.0").RegisterEvent("Cork Seal", "PLAYER_REGEN_ENABLED", function() dataobj.player = nil end)

function dataobj:Scan() self.player = InCombatLockdown() and Test() end
function dataobj:CorkIt() end


----------------------
--      Config      --
----------------------

local GAP = 8
local tekcheck = LibStub("tekKonfig-Checkbox")

local frame = CreateFrame("Frame", nil, UIParent)
frame.name = "Seal"
frame.parent = "Cork"
frame:Hide()

frame:SetScript("OnShow", function()
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Cork - Seal", "These settings are saved on a per-char basis.")

	local enabled = tekcheck.new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	enabled.tiptext = "Toggle this module."
	local checksound = enabled:GetScript("OnClick")
	enabled:SetScript("OnClick", function(self)
		checksound(self)
		Cork.dbpc["Seal-enabled"] = not Cork.dbpc["Seal-enabled"]
		dataobj:Scan()
	end)

	local function Update(self)
		enabled:SetChecked(Cork.dbpc["Seal-enabled"])
	end

	frame:SetScript("OnShow", Update)
	Update(frame)
end)

InterfaceOptions_AddCategory(frame)
