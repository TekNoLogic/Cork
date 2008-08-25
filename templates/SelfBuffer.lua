
local Cork = Cork
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


function Cork:GenerateSelfBuffer(spellname, icon)
	local _, token = UnitClass("player")
	local iconline = self.IconLine(icon, UnitName("player"), token)
	local defaults = Cork.defaultspc
	defaults[spellname.."-enabled"] = true

	local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {type = "cork"})

	local function Test(unit) if Cork.dbpc[spellname.."-enabled"] and not UnitAura("player", spellname) then return iconline end end

	LibStub("AceEvent-3.0").RegisterEvent("Cork "..spellname, "UNIT_AURA", function(event, unit) if unit == "player" then dataobj.player = Test() end end)

	function dataobj:Scan() self.player = Test() end

	function dataobj:CorkIt(frame)
		if self.player then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "player") end
	end


	----------------------
	--      Config      --
	----------------------

	local GAP = 8
	local tekcheck = LibStub("tekKonfig-Checkbox")

	local frame = CreateFrame("Frame", nil, UIParent)
	frame.name = spellname
	frame.parent = "Cork"
	frame:Hide()

	frame:SetScript("OnShow", function()
		local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Cork - "..spellname, "These settings are saved on a per-char basis.")

		local enabled = tekcheck.new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
		enabled.tiptext = "Toggle this module."
		local checksound = enabled:GetScript("OnClick")
		enabled:SetScript("OnClick", function(self)
			checksound(self)
			Cork.dbpc[spellname.."-enabled"] = not Cork.dbpc[spellname.."-enabled"]
			dataobj:Scan()
		end)

		local function Update(self)
			enabled:SetChecked(Cork.dbpc[spellname.."-enabled"])
		end

		frame:SetScript("OnShow", Update)
		Update(frame)
	end)

	InterfaceOptions_AddCategory(frame)
end
