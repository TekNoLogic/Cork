
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

	Cork.defaultspc[modulename.."-spell"] = buffnames[spellidlist[1]]

	local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..modulename, {type = "cork"})

	local function RefreshKnownSpells() -- Refresh in case the player has learned this since login
		for buff in pairs(icons) do if known[buff] == nil then known[buff] = GetSpellInfo(buff) end end
	end

	function dataobj:Init() RefreshKnownSpells() Cork.defaultspc[modulename.."-enabled"] = known[spellname] ~= nil end

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

	local frame = CreateFrame("Frame", nil, Cork.config)
	frame:SetWidth(1) frame:SetHeight(1)
	dataobj.configframe = frame
	frame:Hide()

	frame:SetScript("OnShow", function()
		local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 18, 2, 4
		local buffbuttons = {}

		local function OnClick(self)
			Cork.dbpc[modulename.."-spell"] = self.buff
			for buff,butt in pairs(buffbuttons) do butt:SetChecked(butt == self) end
			dataobj:Scan()
		end

		local function OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.buff, nil, nil, nil, nil, true)
		end
		local function OnLeave() GameTooltip:Hide() end


		local lasticon
		for _,id in ipairs(spellidlist) do
			local buff = buffnames[id]

			local butt = CreateFrame("CheckButton", nil, frame)
			butt:SetWidth(ROWHEIGHT) butt:SetHeight(ROWHEIGHT)

			local tex = butt:CreateTexture(nil, "BACKGROUND")
			tex:SetAllPoints()
			tex:SetTexture(icons[buff])
			tex:SetTexCoord(4/48, 44/48, 4/48, 44/48)
			butt.icon = tex

			butt:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
			butt:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
			butt:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")

			if lasticon then lasticon:SetPoint("RIGHT", butt, "LEFT", -ROWGAP, 0) end

			butt.buff = buff
			butt:SetScript("OnClick", OnClick)
			butt:SetScript("OnEnter", OnEnter)
			butt:SetScript("OnLeave", OnLeave)

			buffbuttons[buff], lasticon = butt, butt
		end
		lasticon:SetPoint("RIGHT", -EDGEGAP, 0)

		local function Update(self)
			RefreshKnownSpells()

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
end
