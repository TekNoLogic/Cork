
local _, token = UnitClass("player")
if token ~= "HUNTER" then return end
local spellname, _, icon = GetSpellInfo(34074)

local Cork = Cork
local UnitAura = Cork.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local iconline_low = Cork.IconLine(icon, 'Low mana', token)

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {type = "cork"})

function dataobj:Init()
	Cork.defaultspc[spellname.."-enabled"] = GetSpellInfo(spellname) ~= nil
	Cork.defaultspc[spellname.."-low threshold"] = 0.2
	Cork.defaultspc[spellname.."-high threshold"] = 0.6
end

local function GetStandardAspect()
	return Cork.dbpc['Aspects-spell'] or spellname
end

local function Test()
	if Cork.dbpc[spellname.."-enabled"] then
		local haveBuff = UnitAura("player", spellname)
		local manaFraction = UnitMana("player") / UnitManaMax("player")
		if haveBuff and manaFraction > Cork.dbpc[spellname.."-high threshold"] then
			local icon = select(3, GetSpellInfo(GetStandardAspect()))
			return Cork.IconLine(icon, 'High mana', token)
		elseif not haveBuff and manaFraction < Cork.dbpc[spellname.."-low threshold"] then
			return iconline_low
		end
	end
end

function dataobj:Scan()
	self.player = Test()
end

local function EventUpdate(event, unit)
	if unit == "player" then
		dataobj:Scan()
	end
end

LibStub("AceEvent-3.0").RegisterEvent("Cork "..spellname, "UNIT_AURA", EventUpdate)
LibStub("AceEvent-3.0").RegisterEvent("Cork "..spellname, "UNIT_MANA", EventUpdate)

function dataobj:CorkIt(frame)
	if self.player then
		if self.player == iconline_low then
			return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "player")
		else
			return frame:SetManyAttributes("type1", "spell", "spell", GetStandardAspect(), "unit", "player")
		end
	end
end

----------------------
--      Config      --
----------------------

local frame = CreateFrame("Frame", nil, Cork.config)
frame:SetWidth(1)
frame:SetHeight(1)
dataobj.configframe = frame
frame:Hide()

frame:SetScript("OnShow", function()

	local function createSlider(parent, setting, tiptext, ...)
		local slider = LibStub("tekKonfig-Slider").newbare(parent, ...)
		slider.tiptext = tiptext
		slider:SetMinMaxValues(0,1)
		slider:SetValueStep(0.05)

		local sliderText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		sliderText:SetPoint("RIGHT", slider, "LEFT")

		slider:SetScript("OnValueChanged", function(self, newvalue)
			newvalue = math.floor(newvalue*20)/20
			Cork.dbpc[spellname.."-"..setting] = newvalue
			sliderText:SetFormattedText("%d%%", newvalue*100)
			dataobj:Scan()
		end)

		return slider
	end

	local sliderHigh = createSlider(frame, 'high threshold', "High mana threshold. Cork will remember you to remove Aspect of the Viper when your mana is above this threshold.", "RIGHT")
	local sliderLow = createSlider(frame, 'low threshold', "Low mana threshold. Cork will remember you to switch to Aspect of the Viper when your mana is under this threshold.", "RIGHT", sliderHigh, "LEFT", -40, 0)

	local function Update(self)
		sliderLow:SetValue(Cork.dbpc[spellname.."-low threshold"])
		sliderHigh:SetValue(Cork.dbpc[spellname.."-high threshold"])
	end

	frame:SetScript("OnShow", Update)
	Update(frame)
end)
