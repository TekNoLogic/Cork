
local Cork = Cork
local SpellCastableOnUnit, IconLine = Cork.SpellCastableOnUnit, Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")


function Cork:GenerateAdvancedSelfBuffer(modulename, spellidlist)
	local spellname, _, defaulticon = GetSpellInfo(spellidlist[1])
	local _, myclass = UnitClass("player")
	local myname = UnitName("player")
	local buffnames, icons, known = {}, {}, {}
	for _,id in pairs(spellidlist) do
		local spellname, _, icon = GetSpellInfo(id)
		buffnames[id], icons[spellname] =  spellname, icon
	end

	local defaults = Cork.defaultspc
	defaults[modulename.."-enabled"] = true
	defaults[modulename.."-spell"] = buffnames[spellidlist[1]]

	local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..modulename, {type = "cork"})

	local function RefreshKnownSpells() -- Refresh in case the player has learned this since login
		for buff in pairs(icons) do if known[buff] == nil then known[buff] = GetSpellInfo(buff) end end
	end

	local function Test()
		if Cork.dbpc[modulename.."-enabled"] then
			for _,buff in pairs(buffnames) do
				local name, _, _, _, _, _, _, isMine = UnitAura("player", buff)
				if name and isMine then return end
			end

			local spell = Cork.dbpc[modulename.."-spell"]
			local icon = icons[spell]
			return IconLine(icon, myname, myclass)
		end
	end

	LibStub("AceEvent-3.0").RegisterEvent("Cork "..modulename, "UNIT_AURA", function(event, unit) if unit == "player" then dataobj.player = Test() end end)

	function dataobj:Scan() self.player = Test() end

	function dataobj:CorkIt(frame)
		RefreshKnownSpells()
		local spell = Cork.dbpc[modulename.."-spell"]
		if self.player then return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", "player") end
	end


	----------------------
	--      Config      --
	----------------------

	local GAP = 8
	local tekcheck = LibStub("tekKonfig-Checkbox")

	local frame = CreateFrame("Frame", nil, UIParent)
	frame.name = modulename
	frame.parent = "Cork"
	frame:Hide()

	frame:SetScript("OnShow", function()
		local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Cork - "..modulename, "These settings are saved on a per-char basis.")

		local enabled = tekcheck.new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
		enabled.tiptext = "Toggle this module."
		local checksound = enabled:GetScript("OnClick")
		enabled:SetScript("OnClick", function(self)
			checksound(self)
			Cork.dbpc[modulename.."-enabled"] = not Cork.dbpc[modulename.."-enabled"]
			dataobj:Scan()
		end)


		local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 24, 2, 4
		local buffbuttons = {}

		local function OnClick(self)
			Cork.dbpc[modulename.."-spell"] = self.buff
			for buff,butt in pairs(buffbuttons) do butt:SetChecked(butt == self) end
			dataobj:Scan()
		end


		local row = CreateFrame("Frame", nil, frame)
		row:SetPoint("TOP", enabled, "BOTTOM", 0, -16)
		row:SetPoint("LEFT", EDGEGAP, 0)
		row:SetPoint("RIGHT", -EDGEGAP, 0)
		row:SetHeight(ROWHEIGHT)


		local lasticon
		for _,id in ipairs(spellidlist) do
			local buff = buffnames[id]

			local butt = CreateFrame("CheckButton", nil, row)
			butt:SetWidth(ROWHEIGHT) butt:SetHeight(ROWHEIGHT)

			local tex = butt:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints()
			tex:SetTexture(icons[buff])
			butt.icon = tex

			butt:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
			butt:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
			butt:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")

			if not lasticon then butt:SetPoint("LEFT", ROWGAP, 0)
			else butt:SetPoint("LEFT", lasticon, "RIGHT", ROWGAP, 0) end

			butt.buff = buff
			butt:SetScript("OnClick", OnClick)

			buffbuttons[buff], lasticon = butt, butt
		end

		local function Update(self)
			RefreshKnownSpells()
			enabled:SetChecked(Cork.dbpc[modulename.."-enabled"])

			for buff,butt in pairs(buffbuttons) do
				butt:SetChecked(Cork.dbpc[modulename.."-spell"] == buff)
				if known[buff] then
					butt:Enable()
					butt.icon:SetVertexColor(1.0, 1.0, 1.0)
				else
					butt:Disable()
					butt.icon:SetVertexColor(0.4, 0.4, 0.4)
				end
			end
		end

		frame:SetScript("OnShow", Update)
		Update(frame)
	end)

	InterfaceOptions_AddCategory(frame)
end
