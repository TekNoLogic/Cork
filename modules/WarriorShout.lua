
local _, c = UnitClass("player")
if c ~= "WARRIOR" then return end


local Cork = Cork
local UnitAura = UnitAura
local SpellCastableOnUnit = Cork.SpellCastableOnUnit
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


local spellidlist = {6673, 469}

local iconline = Cork.IconLine(select(3, GetSpellInfo(spellidlist[1])), "No shout!")
local buffnames = {}
for _,id in pairs(spellidlist) do buffnames[id] = GetSpellInfo(id) end

local defaults = Cork.defaultspc
defaults["Shout-enabled"] = true

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork Shout", {type = "cork"})

local function Test()
	if Cork.dbpc["Shout-enabled"] then
		for _,buff in pairs(buffnames) do if UnitAura("player", buff) then return end end
		return iconline
	end
end

LibStub("AceEvent-3.0").RegisterEvent("Cork Shout", "UNIT_AURA", function(event, unit) if unit == "player" and InCombatLockdown() then dataobj.player = Test() end end)
LibStub("AceEvent-3.0").RegisterEvent("Cork Shout", "PLAYER_REGEN_DISABLED", function() dataobj.player = Test() end)
LibStub("AceEvent-3.0").RegisterEvent("Cork Shout", "PLAYER_REGEN_ENABLED", function() dataobj.player = nil end)

function dataobj:Scan() self.player = InCombatLockdown() and Test() end
function dataobj:CorkIt() end


----------------------
--      Config      --
----------------------

local GAP = 8
local tekcheck = LibStub("tekKonfig-Checkbox")

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Shout"
frame.parent = "Cork"
frame:Hide()

frame:SetScript("OnShow", function()
	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Cork - Shout", "These settings are saved on a per-char basis.")

	local enabled = tekcheck.new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	enabled.tiptext = "Toggle this module."
	enabled:SetScript("OnClick", function(self)
		Cork.dbpc["Shout-enabled"] = not Cork.dbpc["Shout-enabled"]
		dataobj:Scan()
	end)

	local function Update(self)
		enabled:SetChecked(Cork.dbpc["Shout-enabled"])
	end

	frame:SetScript("OnShow", Update)
	Update(frame)
end)

InterfaceOptions_AddCategory(frame)
