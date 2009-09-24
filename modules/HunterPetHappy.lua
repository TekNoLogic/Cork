
local _, c = UnitClass("player")
if c ~= "HUNTER" then return end


local Cork = Cork
local UnitAura = UnitAura
local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local ICON = "Interface\\Icons\\Ability_Hunter_BeastTraining"
local feedpetspell = GetSpellInfo(6991)
local feedpeteffect = GetSpellInfo(1539)

Cork.defaultspc["Pet Happiness-enabled"] = true
Cork.defaultspc["Pet Happiness-macro"] = ""

local dataobj = ldb:NewDataObject("Cork Pet Happiness", {type = "cork"})

local function Test()
	if Cork.dbpc["Pet Happiness-enabled"] and UnitExists("pet") and not UnitIsDeadOrGhost("pet") and (GetPetHappiness() or 3) ~= 3 and not UnitAura("pet", feedpeteffect) then
		return IconLine(ICON, UnitName("pet").." is hungry")
	end
end

function dataobj:Scan() dataobj.pet = Test() end

ae.RegisterEvent("Cork Pet Happiness", "UNIT_AURA", function(event, unit) if unit == "pet" then dataobj.pet = Test() end end)
ae.RegisterEvent("Cork Pet Happiness", "UNIT_PET", function(event, unit) if unit == "player" then dataobj.pet = Test() end end)
ae.RegisterEvent("Cork Pet Happiness", "UNIT_HAPPINESS", dataobj.Scan)


function dataobj:CorkIt(frame)
	local macro = Cork.dbpc["Pet Happiness-macro"]
	if self.pet and macro ~= "" then return frame:SetManyAttributes("type1", "macro", "macrotext1", macro) end
end


----------------------
--      Config      --
----------------------

local frame = CreateFrame("Frame", nil, Cork.config)
frame:SetWidth(1) frame:SetHeight(1)
dataobj.configframe = frame
frame:Hide()

frame:SetScript("OnShow", function()
	local function MakeMacro()
		local infotype, itemid, itemlink = GetCursorInfo()
		if infotype == "merchant" then itemid = tonumber(GetMerchantItemLink(itemid):match("item:(%d+):")) end
		if infotype == "item" or infotype == "merchant" then Cork.dbpc["Pet Happiness-macro"] = "/cast "..feedpetspell.."\n/use item:"..itemid end
		return ClearCursor()
	end


	local editbox = CreateFrame("EditBox", nil, frame)
	editbox:SetWidth(300)
	editbox:SetPoint("RIGHT")
	editbox:SetFrameStrata("DIALOG")
	editbox:Hide()
	editbox:SetFontObject(GameFontHighlightSmall)
	editbox:SetTextInsets(8,8,8,8)
	editbox:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4}
	})
	editbox:SetBackdropColor(.3, .1, .1, 1)
	editbox:SetMultiLine(true)
	editbox:SetAutoFocus(true)
	editbox:SetScript("OnShow", function(self) self:SetText(Cork.dbpc["Pet Happiness-macro"]) end)
	editbox:SetScript("OnHide", function(self) Cork.dbpc["Pet Happiness-macro"] = self:GetText() end)
	editbox:SetScript("OnEscapePressed", editbox.Hide)
	editbox:SetScript("OnReceiveDrag", function()
		MakeMacro()
		self:SetText(Cork.dbpc["Pet Happiness-macro"])
	end)


	local butt = LibStub("tekKonfig-Button").new_small(frame, "RIGHT")
	butt:SetWidth(60) butt:SetHeight(18)
	butt.tiptext = "Click to edit macro, or drop an item to automatically generate a macro."
	butt:SetText("Macro")
	butt:SetScript("OnClick", function() editbox:Show() end)
	butt:SetScript("OnReceiveDrag", MakeMacro)


	frame:SetScript("OnHide", function() editbox:Hide() end)
	frame:SetScript("OnShow", nil)
end)


local orig = IsOptionFrameOpen
function IsOptionFrameOpen(...)
	if not frame:IsVisible() then return orig(...) end
end
