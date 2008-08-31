
local _, c = UnitClass("player")
if c ~= "PRIEST" then return end


local Cork = Cork
local UnitAura = Cork.UnitAura or UnitAura
local SpellCastableOnUnit = Cork.SpellCastableOnUnit
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local spellname, _, icon = GetSpellInfo(6346)
local iconline = Cork.IconLine(icon, spellname)
local buffnames = {}

local defaults = Cork.defaultspc
defaults[spellname.."-enabled"] = false

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {type = "cork"})

local myunit = "player"
local f = CreateFrame("Frame")
f:Hide()

local endtime, elapsed
local function Test()
	if not Cork.dbpc[spellname.."-enabled"] then
		f:Hide()
		return
	end

	local start, duration = GetSpellCooldown(spellname)
	if start == 0 then return iconline
	else
		endtime = start + duration
		f:Show()
	end
end

f:SetScript("OnShow", function() elapsed = GetTime() end)
f:SetScript("OnHide", function() dataobj.player, endtime = Test() end)
f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if not endtime or elapsed >= endtime then self:Hide() end
end)

ae.RegisterEvent("Cork "..spellname, "UNIT_SPELLCAST_SUCCEEDED", function(event, unit, spell) if unit == "player" and spell == spellname then dataobj.player = Test() end end)

function dataobj:Init() Cork.dbpc[spellname.."-enabled"] = nil end -- We don't want to save across sessions
function dataobj:Scan() self.player = Test() end

function dataobj:CorkIt(frame)
	if self.player then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", myunit) end
end


----------------------
--      Config      --
----------------------

local frame = CreateFrame("Frame", nil, Cork.config)
frame:SetWidth(1) frame:SetHeight(1)
dataobj.configframe = frame
frame:Hide()

frame:SetScript("OnShow", function()
	local dd, ddtext = LibStub("tekKonfig-Dropdown").new(frame)
	dd.tiptext = "Select target for Fear Ward."
	dd:SetPoint("RIGHT", frame, "RIGHT", 0, -4)

	local name = UnitName("player")
	ddtext:SetText(name)
	UIDropDownMenu_SetSelectedValue(dd, name)

	local function OnClick(self)
		UIDropDownMenu_SetSelectedValue(dd, self.value)
		ddtext:SetText(self.value)
		myunit = self.value
	end
	UIDropDownMenu_Initialize(dd, function()
		local selected, info = UIDropDownMenu_GetSelectedValue(dd), UIDropDownMenu_CreateInfo()

		local raidnum, partynum = GetNumRaidMembers(), GetNumPartyMembers()

		if raidnum > 0 then
			for i=1,raidnum do
				local name = UnitName("raid"..i)
				info.text, info.value, info.func, info.checked = name, name, OnClick, name == selected
				UIDropDownMenu_AddButton(info)
			end
		else
			local name = UnitName("player")
			info.text, info.value, info.func, info.checked = name, name, OnClick, name == selected
			UIDropDownMenu_AddButton(info)

			for i=1,partynum do
				local name = UnitName("party"..i)
				info.text, info.value, info.func, info.checked = name, name, OnClick, name == selected
				UIDropDownMenu_AddButton(info)
			end
		end
	end)

	frame:SetScript("OnShow", nil)
end)
