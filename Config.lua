

local myname, Cork = ...
local ns = Cork

local GAP = 8
local tekcheck = LibStub("tekKonfig-Checkbox")


local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
Cork.config = frame
frame.name = "Cork"
frame:Hide()

frame:SetScript("OnShow", function()
	local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 16, 2, 4

	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Cork", "Most of these settings are saved on a per-talent spec basis.  Settings will automatically switch when you swap specs.")

	local showanchor = tekcheck.new(frame, nil, "Show anchor", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	showanchor.tiptext = "Toggle the tooltip anchor. \n|cffffff9aThis setting is global."
	showanchor:SetScript("OnClick", function(self)
		Cork.db.showanchor = not Cork.db.showanchor
		if Cork.db.showanchor then Cork.anchor:Show() else Cork.anchor:Hide() end
	end)


	local resetanchor = LibStub("tekKonfig-Button").new_small(frame, "LEFT", showanchor, "RIGHT", 105, 0)
	resetanchor:SetWidth(60) resetanchor:SetHeight(18)
	resetanchor.tiptext = "Click to reset the anchor to it's default position. \n|cffffff9aPosition is a global setting."
	resetanchor:SetText("Reset")
	resetanchor:SetScript("OnClick", function()
		Cork.db.point, Cork.db.x, Cork.db.y = nil
		Cork.anchor:ClearAllPoints()
		Cork.anchor:SetPoint(Cork.db.point, Cork.db.x, Cork.db.y)
		Cork.Update()
	end)


	local showbg = tekcheck.new(frame, nil, "Show toolip in BG", "TOPLEFT", showanchor, "BOTTOMLEFT", 0, -GAP)
	showbg.tiptext = "Show the tooltip when in a battleground or outdoor PvP zone.  When the tooltip is hidden the macro will still work."
	showbg:SetScript("OnClick", function(self)
		Cork.db.showbg = not Cork.db.showbg
		Cork.Update()
	end)


	local bindwheel = tekcheck.new(frame, nil, "Bind mousewheel", "TOPLEFT", showbg, "BOTTOMLEFT", 0, -GAP)
	bindwheel.tiptext = "Bind to mousewheel when out of combat and needs are present. \n|cffffff9aThis setting is global."
	bindwheel:SetScript("OnClick", function(self)
		Cork.db.bindwheel = not Cork.db.bindwheel
		Cork.UpdateMouseBinding()
	end)


	if tekDebug then
		local showunit = tekcheck.new(frame, nil, "Debug mode", "TOPLEFT", bindwheel, "BOTTOMLEFT", 0, -GAP)
		showunit.tiptext = "Ignores rest state and shows unitIDs (target, party1, raidpet5) in tooltip."
		showunit:SetChecked(Cork.db.debug)
		showunit:SetScript("OnClick", function(self)
			Cork.db.debug = not Cork.db.debug
			Cork.Update()
		end)
	end

	local group = LibStub("tekKonfig-Group").new(frame, nil, "TOP", subtitle, "BOTTOM", 0, -GAP-22)
	group:SetPoint("LEFT", frame, "CENTER", -40, 0)
	group:SetPoint("BOTTOMRIGHT", -EDGEGAP, EDGEGAP)


	local macrobutt = LibStub("tekKonfig-Button").new_small(frame, "BOTTOMRIGHT", group, "TOPRIGHT")
	macrobutt:SetWidth(60) macrobutt:SetHeight(18)
	macrobutt.tiptext = "Click to generate a macro, or pick it up if already generated."
	macrobutt:SetText("Macro")
	macrobutt:SetScript("OnClick", Cork.GenerateMacro)


	local corknames, rows, anchor = {}, {}
	local tekcheck = LibStub("tekKonfig-Checkbox")
	local NUMROWS = math.floor((group:GetHeight()-EDGEGAP+ROWGAP + 2) / (ROWHEIGHT+ROWGAP))
	for _,cork in pairs(Cork.corks) do table.insert(corknames, (cork.name:gsub("Cork ", ""))) end
	table.sort(corknames)

	local function OnClick(self)
		Cork.dbpc[self.name.."-enabled"] = not Cork.dbpc[self.name.."-enabled"]
		PlaySound(Cork.dbpc[self.name.."-enabled"] and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
		self.cork:Scan()
	end

	for i=1,NUMROWS do
		local name = corknames[i]
		if name then
			local row = CreateFrame("Button", nil, group)
			table.insert(rows, row)

			if anchor then row:SetPoint("TOP", anchor , "BOTTOM", 0, -ROWGAP)
			else row:SetPoint("TOP", 0, -EDGEGAP/2) end
			row:SetPoint("LEFT", EDGEGAP/2, 0)
			row:SetPoint("RIGHT", -EDGEGAP/2, 0)
			row:SetHeight(ROWHEIGHT)
			anchor = row


			local check = tekcheck.new(row, ROWHEIGHT+4, nil, "LEFT")
			check:SetScript("OnClick", OnClick)
			row.check = check


			local title = row:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
			title:SetPoint("LEFT", check, "RIGHT", 4, 0)
			row.title = title
		end
	end

	local currenttab = 'buff'
	local function UpdateRows()
		for i,row in pairs(rows) do
			row:Hide()
			if row.configframe then row.configframe:Hide() end
		end

		local i = 1
		for j,cork in ipairs(Cork.sortedcorks) do
			if cork.corktype == currenttab then
				local row = rows[i]
				if not row then return end
				i = i + 1

				row.check.cork = cork
				row.check.name = cork.name
				row.check.tiptext = cork.tiptext
				row.check.tiplink = cork.tiplink
				row.check:SetChecked(Cork.dbpc[cork.name.."-enabled"])

				row.title:SetText(cork.name)

				local configframe = cork.configframe
				row.configframe = configframe
				if configframe then
					configframe:SetPoint("RIGHT", row)
					configframe:SetFrameLevel(row:GetFrameLevel() + 1)
					configframe:Show()
				end

				row:Show()
			end
		end
	end


	local tab1 = ns.NewTab(frame, "Buffs", "BOTTOMLEFT", group, "TOPLEFT", 0, -4)
	local tab2 = ns.NewTab(frame, "Items", "LEFT", tab1, "RIGHT", -15, 0)
	local tab3 = ns.NewTab(frame, "Other", "LEFT", tab2, "RIGHT", -15, 0)
	tab2:Deactivate()
	tab3:Deactivate()

	tab1:SetScript("OnClick", function(self)
		self:Activate()
		tab2:Deactivate()
		tab3:Deactivate()
		currenttab = 'buff'
		UpdateRows()
	end)

	tab2:SetScript("OnClick", function(self)
		self:Activate()
		tab1:Deactivate()
		tab3:Deactivate()
		currenttab = 'item'
		UpdateRows()
	end)

	tab3:SetScript("OnClick", function(self)
		self:Activate()
		tab1:Deactivate()
		tab2:Deactivate()
		currenttab = nil
		UpdateRows()
	end)


	frame.Update = function(self)
		if not self:IsVisible() then return end
		showanchor:SetChecked(Cork.db.showanchor)
		showbg:SetChecked(Cork.db.showbg)
		bindwheel:SetChecked(Cork.db.bindwheel)
		UpdateRows()
	end

	frame:SetScript("OnShow", frame.Update)
	frame:Update()
end)

InterfaceOptions_AddCategory(frame)


----------------------------
--      LDB Launcher      --
----------------------------

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:GetDataObjectByName("CorkLauncher") or ldb:NewDataObject("CorkLauncher", {type = "launcher", icon = "Interface\\Icons\\INV_Drink_11", tocname = "Cork"})
dataobj.OnClick = function() InterfaceOptionsFrame_OpenToCategory(frame) end


----------------------------
--       Key Binding      --
----------------------------

setglobal("BINDING_HEADER_CORK", "Cork")
setglobal("BINDING_NAME_CLICK CorkFrame:LeftButton", "Click the Cork frame")
