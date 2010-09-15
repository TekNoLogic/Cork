
local myname, Cork = ...
if Cork.MYCLASS ~= "PALADIN" then return end


local myname, Cork = ...
local UnitAura = UnitAura
local IsSpellInRange, SpellCastableOnUnit, IconLine = Cork.IsSpellInRange, Cork.SpellCastableOnUnit, Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
Cork.hasraidspell = true

local blist = {npc = true, vehicle = true}
for i=1,5 do blist["arena"..i], blist["arenapet"..i] = true, true end


if Cork.IHASCAT then
	-- Mark of the Wild and Blessing or Kings are now the same buff
	-- Blessing of Might is the only other blessing
	-- Both of these hit the entire raid now
	-- and pet are not buffable anymore

	-- So, this is the logic we need:
	-- If the unit has a buff from you, or has both kings/mark and might, skip them
	-- If there is a druid in the group, you have the kings drums, or units have kings/forgotten kings on them, cast might
	-- Otherwise, cast kings

	local MARK, FORGOTTEN_KINGS = GetSpellInfo(1126), GetSpellInfo(69378)
	local KINGS, _, KINGSICON = GetSpellInfo(20217)
	local MIGHT, _, MIGHTICON = GetSpellInfo(19740)
	local GMIGHT, GWISDOM, GSANC, GKINGS = GetSpellInfo(25782), GetSpellInfo(25894), GetSpellInfo(25899), GetSpellInfo(25898)


	local blessings = {[MIGHT] = GMIGHT, [KINGS] = GKINGS}
	local icons = {[MIGHT] = MIGHTICON, [KINGS] = KINGSICON}
	local mightier, known = {}, {}
	for blessing,greater in pairs(blessings) do known[blessing], known[greater] = GetSpellInfo(blessing), GetSpellInfo(greater) end


	local function RefreshKnownSpells()
		for blessing,greater in pairs(blessings) do -- Refresh in case the player has learned this since login
			if known[blessing] == nil then known[blessing] = GetSpellInfo(blessing) end
			if known[greater] == nil then known[greater] = GetSpellInfo(greater) end
		end
	end


	local function FurryInParty()
		for i=1,GetNumRaidMembers() do if select(2, UnitClass("raid"..i)) == "DRUID" then return true end end
		for i=1,GetNumPartyMembers() do if select(2, UnitClass("party"..i)) == "DRUID" then return true end end
	end


	local function NeededBlessing(unit)
		local hasMark = UnitAura(unit, MARK)
		local hasForgottenKings = UnitAura(unit, FORGOTTEN_KINGS)
		local hasKings, _, _, _, _, _, _, myKings = UnitAura(unit, KINGS)
		local hasMight, _, _, _, _, _, _, myMight = UnitAura(unit, MIGHT)
		local drummer = GetItemCount(49633) > 0
		if myKings or myMight or (hasMark or hasKings) and hasMight then return end
		if (hasMark or hasKings or hasForgottenKings or drummer or FurryInParty() or select(2, UnitClass(unit)) == "DRUID") and not hasMight then return MIGHT end
		return KINGS
	end


	local defaults = Cork.defaultspc
	defaults["Blessings-enabled"] = true


	local dataobj = ldb:NewDataObject("Cork Blessings", {type = "cork", tiptext = "Attempts to pick the best blessing to cast based on your group.  Kings is preferred, except in cases where it can be provided by another means like a druid, forgotten kings drums, or another pally.\n\nNote: the icon will not always show which spell will be cast, that is determined at the time you cast."})

	-- function dataobj:Init() known = {} RefreshKnownSpells() end

	local function Test(unit)
		if not Cork.dbpc["Blessings-enabled"] or (IsResting() and not Cork.db.debug) or not Cork:ValidUnit(unit, true) then
			-- mightier[unit] = nil
			return
		end
		local spell = NeededBlessing(unit)
		if spell then
			-- mightier[unit] = spell == MIGHT or nil -- We don't want to store a false, that'll mess up next()
			local _, class = UnitClass(unit)
			-- local icon = icons[spell]
			return IconLine(KINGSICON, UnitName(unit), class)
		end
	end
	Cork:RegisterRaidEvents("Blessings", dataobj, Test)
	dataobj.Scan = Cork:GenerateRaidScan(Test)

	ae.RegisterEvent(dataobj, "PLAYER_UPDATE_RESTING", "Scan")


	function dataobj:CorkIt(frame)
		-- local spellname = next(mightier) and MIGHT or KINGS

		-- local numraid, numparty = GetNumRaidMembers(), GetNumPartyMembers()
		-- for i=1,numraid do if self["raid"..i] and NeededBlessing("raid"..i) == MIGHT and SpellCastableOnUnit(spellname, unit) then frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "raid"..i) end end
		-- for i=1,numparty do if self["party"..i] and NeededBlessing("party"..i) == MIGHT then frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "party"..i) end end

		-- if self.player and SpellCastableOnUnit(spellname, "player") then
		-- 	return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "player")
		-- end
		for unit in ldb:pairs(self) do
			if Cork.petmappings[unit] and NeededBlessing(unit) == MIGHT and SpellCastableOnUnit(MIGHT, unit) then
				return frame:SetManyAttributes("type1", "spell", "spell", MIGHT, "unit", unit)
			end
		end
		for unit in ldb:pairs(self) do
			if Cork.petmappings[unit] and SpellCastableOnUnit(KINGS, unit) then
				return frame:SetManyAttributes("type1", "spell", "spell", KINGS, "unit", unit)
			elseif not Cork.petmappings[unit] then
				local spell = NeededBlessing(unit)
				if SpellCastableOnUnit(spell, unit) then return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", unit) end
			end
		end
		-- for unit in ldb:pairs(self) do if SpellCastableOnUnit(spellname, unit) then return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", unit) end end
	end

else
	local MIGHT, _, MIGHTICON = GetSpellInfo(19740)
	local WISDOM, _, WISDOMICON = GetSpellInfo(19742)
	local SANC, _, SANCICON = GetSpellInfo(20911)
	local KINGS, _, KINGSICON = GetSpellInfo(20217)
	local GMIGHT, GWISDOM, GSANC, GKINGS = GetSpellInfo(25782), GetSpellInfo(25894), GetSpellInfo(25899), GetSpellInfo(25898)


	local blessings = {[MIGHT] = GMIGHT, [WISDOM] = GWISDOM, [SANC] = GSANC, [KINGS] = GKINGS}
	local icons = {[MIGHT] = MIGHTICON, [WISDOM] = WISDOMICON, [SANC] = SANCICON, [KINGS] = KINGSICON}
	local known = {}
	for blessing,greater in pairs(blessings) do known[blessing], known[greater] = GetSpellInfo(blessing), GetSpellInfo(greater) end


	local function RefreshKnownSpells()
		for blessing,greater in pairs(blessings) do -- Refresh in case the player has learned this since login
			if known[blessing] == nil then known[blessing] = GetSpellInfo(blessing) end
			if known[greater] == nil then known[greater] = GetSpellInfo(greater) end
		end
	end


	local function HasMyBlessing(unit)
		local inrange = IsSpellInRange(MIGHT, unit)
		for blessing,greater in pairs(blessings) do
			local name, _, _, _, _, _, _, isMine = UnitAura(unit, greater)
			if name and (not inrange or isMine == "player") then return true end
			local name, _, _, _, _, _, _, isMine = UnitAura(unit, blessing)
			if name and (not inrange or isMine == "player") then return true end
		end
	end


	local defaults = Cork.defaultspc
	defaults["Blessings-enabled"] = true
	defaults["Blessings-solo"] = false
	defaults["Blessings-party"] = true
	defaults["Blessings-bgarena"] = false
	defaults["Blessings-PRIEST"] = WISDOM
	defaults["Blessings-SHAMAN"] = WISDOM
	defaults["Blessings-MAGE"] = WISDOM
	defaults["Blessings-WARLOCK"] = WISDOM
	defaults["Blessings-DRUID"] = WISDOM
	defaults["Blessings-PALADIN"] = MIGHT
	defaults["Blessings-HUNTER"] = MIGHT
	defaults["Blessings-ROGUE"] = MIGHT
	defaults["Blessings-WARRIOR"] = MIGHT
	defaults["Blessings-DEATHKNIGHT"] = MIGHT


	local dataobj = ldb:NewDataObject("Cork Blessings", {type = "cork"})

	function dataobj:Init() known = {} RefreshKnownSpells() end

	local function Test(unit)
		if not Cork.dbpc["Blessings-enabled"] or (IsResting() and not Cork.db.debug) or not Cork:ValidUnit(unit, true) then return end
		local _, class = UnitClass(unit)
		if class and not HasMyBlessing(unit) then
			local spell = Cork.dbpc["Blessings-"..class]
			local icon = icons[spell]
			return IconLine(icon, UnitName(unit), class)
		end
	end
	Cork:RegisterRaidEvents("Blessings", dataobj, Test)
	dataobj.Scan = Cork:GenerateRaidScan(Test)

	ae.RegisterEvent(dataobj, "PLAYER_UPDATE_RESTING", "Scan")


	function dataobj:CorkIt(frame)
		RefreshKnownSpells()

		local numraid, numparty, _, instanceType = GetNumRaidMembers(), GetNumPartyMembers(), IsInInstance()
		local usegreaters = true
		if instanceType == "arena" or instanceType == "pvp" then usegreaters = Cork.dbpc["Blessings-bgarena"]
		elseif numraid == 0 and numparty > 0 then usegreaters = Cork.dbpc["Blessings-party"]
		elseif numraid == 0 and numparty == 0 then usegreaters = Cork.dbpc["Blessings-solo"] end

		for unit in ldb:pairs(self) do
			if not Cork.keyblist[unit] then
				local _, class = UnitClass(unit)
				local spell = Cork.dbpc["Blessings-"..class]
				local greater = blessings[spell]
				if usegreaters and GetSpellCount(greater) > 0 then
					if known[greater] and SpellCastableOnUnit(greater, unit) then return frame:SetManyAttributes("type1", "spell", "spell", greater, "unit", unit) end
				end
				if known[spell] and SpellCastableOnUnit(spell, unit) then return frame:SetManyAttributes("type1", "spell", "spell", spell, "unit", unit) end
			end
		end
	end


	----------------------
	--      Config      --
	----------------------

	local GAP = 8
	local tekcheck = LibStub("tekKonfig-Checkbox")

	local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
	frame.name = "Blessings"
	frame.parent = "Cork"
	frame:Hide()

	frame:SetScript("OnShow", function()
		local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Cork - Blessings", "Greater blessings are always used in raids.  These settings are saved on a per-talent spec basis.  Settings will automatically switch when you swap specs.")

		local enabled = tekcheck.new(frame, nil, "Enabled", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
		enabled.tiptext = "Toggle this module."
		local function toggle(self)
			Cork.dbpc["Blessings-"..self.sv] = not Cork.dbpc["Blessings-"..self.sv]
			dataobj:Scan()
		end
		enabled.sv = "enabled"
		enabled:SetScript("OnClick", toggle)


		local useparty = tekcheck.new(frame, nil, "Party", "TOPLEFT", enabled, "BOTTOMLEFT", 0, -GAP)
		useparty.tiptext = "Use greater blessings when in a party."
		useparty.sv = "party"
		useparty:SetScript("OnClick", toggle)


		local usebgarena = tekcheck.new(frame, nil, "BG/Arena", "TOPLEFT", useparty, "BOTTOMLEFT", 0, -GAP)
		usebgarena.tiptext = "Use greater blessings when in a battleground or arena."
		usebgarena.sv = "bgarena"
		usebgarena:SetScript("OnClick", toggle)


		local usesolo = tekcheck.new(frame, nil, "Solo", "TOPLEFT", usebgarena, "BOTTOMLEFT", 0, -GAP)
		usesolo.tiptext = "Use greater blessings when not in a group."
		usesolo.sv = "solo"
		usesolo:SetScript("OnClick", toggle)


		local mwbutt = LibStub("tekKonfig-Button").new_small(frame)
		mwbutt:SetWidth(25)
		mwbutt:SetText("All")
		mwbutt.tiptext = "Set all classes to receive Blessing of Might or Wisdom"


		local kingsbutt = LibStub("tekKonfig-Button").new_small(frame)
		kingsbutt:SetWidth(25)
		kingsbutt:SetText("All")
		kingsbutt.tiptext = "Set all classes to receive Blessing of Kings"


		local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 22, 2, 4
		local BUFFS = {SANC, KINGS, WISDOM, MIGHT}

		local function OnClick(self)
			Cork.dbpc["Blessings-"..self.token] = self.buff
			for _,butt in pairs(self.buffbuttons) do butt:SetChecked(butt == self) end
			dataobj:Scan()
		end

		local function OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetHyperlink(GetSpellLink(self.buff))
		end
		local function OnLeave() GameTooltip:Hide() end

		local group = LibStub("tekKonfig-Group").new(frame, "Classes", "TOP", enabled, "TOP", 0, -8)
		group:SetPoint("LEFT", frame, "CENTER", -60, 0)
		group:SetPoint("BOTTOMRIGHT", -EDGEGAP, EDGEGAP)

		local rows, anchor = {}
		local ROWHEIGHT = (group:GetHeight() - EDGEGAP)/#CLASS_SORT_ORDER - ROWGAP
		for _,token in pairs(CLASS_SORT_ORDER) do
			local class = Cork.classnames[token]

			local row = CreateFrame("Frame", nil, group)
			if not anchor then row:SetPoint("TOP", 0, -EDGEGAP/2)
			else row:SetPoint("TOP", anchor, "BOTTOM", 0, -ROWGAP) end
			row:SetPoint("LEFT", EDGEGAP/2, 0)
			row:SetPoint("RIGHT", -EDGEGAP/2, 0)
			row:SetHeight(ROWHEIGHT)
			rows[token], anchor = row, row


			local name = row:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
			name:SetPoint("LEFT", 4, 0)
			name:SetText("|cff".. Cork.colors[token].. class)

			local lasticon
			row.buffbuttons = {}
			for i,buff in ipairs(BUFFS) do
				local butt = CreateFrame("CheckButton", nil, row)
				butt:SetWidth(ROWHEIGHT) butt:SetHeight(ROWHEIGHT)

				local tex = butt:CreateTexture(nil, "BACKGROUND")
				tex:SetAllPoints()
				tex:SetTexture(icons[buff])
				tex:SetTexCoord(4/48, 44/48, 4/48, 44/48)
				butt.icon = tex

				butt:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
				butt:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
				butt:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")

				if not lasticon then butt:SetPoint("RIGHT", -ROWGAP, 0)
				else butt:SetPoint("RIGHT", lasticon, "LEFT", -ROWGAP, 0) end

				butt.token, butt.buff, butt.buffbuttons = token, buff, row.buffbuttons
				butt:SetScript("OnClick", OnClick)
				butt:SetScript("OnEnter", OnEnter)
				butt:SetScript("OnLeave", OnLeave)

				row.buffbuttons[buff], lasticon = butt, butt
			end
		end

		kingsbutt:SetPoint("BOTTOM", rows[CLASS_SORT_ORDER[1]].buffbuttons[KINGS], "TOP", 0, 7)
		mwbutt:SetPoint("BOTTOM", rows[CLASS_SORT_ORDER[1]].buffbuttons[WISDOM], "TOPLEFT", -ROWGAP/2, 7)

		local function Update(self)
			RefreshKnownSpells()

			enabled:SetChecked(Cork.dbpc["Blessings-enabled"])
			usesolo:SetChecked(Cork.dbpc["Blessings-solo"])
			usebgarena:SetChecked(Cork.dbpc["Blessings-bgarena"])
			useparty:SetChecked(Cork.dbpc["Blessings-party"])

			for token,row in pairs(rows) do
				for buff,butt in pairs(row.buffbuttons) do
					butt:SetChecked(Cork.dbpc["Blessings-"..token] == buff)
					if known[buff] then
						butt:Enable()
						butt.icon:SetVertexColor(1.0, 1.0, 1.0)
					else
						butt:Disable()
						butt.icon:SetVertexColor(0.4, 0.4, 0.4)
					end
				end
			end
		end

		mwbutt:SetScript("OnClick", function() for _,token in pairs(CLASS_SORT_ORDER) do Cork.dbpc["Blessings-"..token] = nil end; Update(frame); dataobj:Scan() end)
		kingsbutt:SetScript("OnClick", function() for _,token in pairs(CLASS_SORT_ORDER) do Cork.dbpc["Blessings-"..token] = KINGS end; Update(frame); dataobj:Scan() end)

		frame:SetScript("OnShow", Update)
		Update(frame)
	end)

	InterfaceOptions_AddCategory(frame)


	--------------------------
	--      Sub-config      --
	--------------------------

	local frame2 = CreateFrame("Frame", nil, Cork.config)
	frame2:SetWidth(1) frame2:SetHeight(1)
	dataobj.configframe = frame2
	frame2:Hide()

	frame2:SetScript("OnShow", function()
		local butt = LibStub("tekKonfig-Button").new_small(frame2, "RIGHT")
		butt:SetWidth(60) butt:SetHeight(18)
		butt.tiptext = "Click to open detailed config."
		butt:SetText("Config")
		butt:SetScript("OnClick", function() InterfaceOptionsFrame_OpenToCategory(frame) end)

		frame2:SetScript("OnShow", nil)
	end)
end