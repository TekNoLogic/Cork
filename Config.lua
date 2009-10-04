

local Cork = Cork

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
	local checksound = showanchor:GetScript("OnClick")
	showanchor:SetScript("OnClick", function(self)
		checksound(self)
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
	showbg.tiptext = "Show the tooltip when in a battleground or Wintergrasp.  When the tooltip is hidden the macro will still work."
	showbg:SetScript("OnClick", function(self)
		checksound(self)
		Cork.db.showbg = not Cork.db.showbg
		Cork.Update()
	end)


	local showunit = tekcheck.new(frame, nil, "Show unitID", "TOPLEFT", showbg, "BOTTOMLEFT", 0, -GAP)
	showunit.tiptext = "Show unitID (target, party1, raidpet5) in tooltip. \n|cffffff9aThis setting is global."
	showunit:SetScript("OnClick", function(self)
		checksound(self)
		Cork.db.showunit = not Cork.db.showunit
		Cork.Update()
	end)


	local bindwheel = tekcheck.new(frame, nil, "Bind mousewheel", "TOPLEFT", showunit, "BOTTOMLEFT", 0, -GAP)
	bindwheel.tiptext = "Bind to mousewheel when out of combat and needs are present. \n|cffffff9aThis setting is global."
	bindwheel:SetScript("OnClick", function(self)
		checksound(self)
		Cork.db.bindwheel = not Cork.db.bindwheel
		Cork.UpdateMouseBinding()
	end)


	local tooltiplimit, tooltiplimittext, ttlcontainer = LibStub("tekKonfig-Slider").new(frame, "Tooltip Limit: " .. Cork.dbpc.tooltiplimit, 0, 40, "TOP", showanchor, "TOP")
	ttlcontainer:SetPoint("LEFT", frame, "CENTER", GAP*5/2, 0)
	tooltiplimit.tiptext = "The number of units to show in the Cork tooltip."
	tooltiplimit:SetValueStep(1)
	tooltiplimit:SetValue(Cork.dbpc.tooltiplimit)
	tooltiplimit:SetScript("OnValueChanged", function(self, newvalue)
		Cork.dbpc.tooltiplimit = newvalue
		tooltiplimittext:SetText("Tooltip Limit: " .. newvalue)
		Cork.Update()
	end)


	local castonpets, groupthresh, groupthreshtext, groupthreshcont
	if Cork.hasgroupspell then
		groupthresh, groupthreshtext, groupthreshcont = LibStub("tekKonfig-Slider").new(frame, "Group Threshold: ".. Cork.dbpc.multithreshold, 1, 6, "TOPLEFT", ttlcontainer, "BOTTOMLEFT") --, GAP*2, -GAP)
		groupthresh.tiptext = "Minimum number of needy players in a group required to cast multi-target spells.  Setting this to six will disable the automatic use of group spells when in a party."
		groupthresh:SetValueStep(1)
		groupthresh:SetScript("OnValueChanged", function(self, newvalue)
			Cork.dbpc.multithreshold = newvalue
			groupthreshtext:SetText("Group Threshold: ".. newvalue)
		end)

--~ 		castonpets = tekcheck.new(frame, nil, "Cast on group pets", "TOPLEFT", groupthreshcont, "BOTTOMLEFT", -GAP*2, 0)
		castonpets = tekcheck.new(frame, nil, "Cast on group pets", "TOPLEFT", bindwheel, "BOTTOMLEFT", 0, -GAP)
		castonpets.tiptext = "Pets need buffs too!  When disabled you can still cast on a pet by targetting it directly."
		castonpets:SetScript("OnClick", function(self)
			checksound(self)
			Cork.dbpc.castonpets = not Cork.dbpc.castonpets
			for name,dataobj in pairs(Cork.corks) do dataobj:Scan() end
		end)
	end

	if Cork.hasgroupspell or Cork.hasraidspell then
		local raidgroupdropdown, raidgroupdropdowntext, raidgroupdropdowncontainer, raidgroupdropdownlabel = LibStub("tekKonfig-Dropdown").new(frame, "Raid mode", "TOPLEFT", groupthreshcont or ttlcontainer, "BOTTOMLEFT", -12, -6)
		raidgroupdropdowncontainer:SetHeight(28)
		raidgroupdropdown:SetWidth(120)
		raidgroupdropdown:ClearAllPoints()
		raidgroupdropdown:SetPoint("LEFT", raidgroupdropdownlabel, "RIGHT", -8, -2)
		raidgroupdropdowntext:SetText((Cork.dbpc.raid_thresh*5).."-man")
		raidgroupdropdown.tiptext = "Select which raid groups should be monitored for buffs."

		local function OnClick(self)
			raidgroupdropdowntext:SetText((self.value*5).."-man")
			Cork.dbpc.raid_thresh = self.value
			for name,dataobj in pairs(Cork.corks) do dataobj:Scan() end
		end
		UIDropDownMenu_Initialize(raidgroupdropdown, function()
			local selected, info = (Cork.dbpc.raid_thresh*5).."-man", UIDropDownMenu_CreateInfo()

			info.func = OnClick

			info.text = "10-man"
			info.value = 2
			info.checked = "10-man" == selected
			UIDropDownMenu_AddButton(info)

			info.text = "25-man"
			info.value = 5
			info.checked = "25-man" == selected
			UIDropDownMenu_AddButton(info)

			info.text = "40-man"
			info.value = 8
			info.checked = "40-man" == selected
			UIDropDownMenu_AddButton(info)
		end)
	end


	local group = LibStub("tekKonfig-Group").new(frame, "Modules", "TOP", castonpets or bindwheel, "BOTTOM", 0, -27)
	group:SetPoint("LEFT", EDGEGAP, 0)
	group:SetPoint("BOTTOMRIGHT", -EDGEGAP, EDGEGAP)


	local macrobutt = LibStub("tekKonfig-Button").new_small(frame, "BOTTOMRIGHT", group, "TOPRIGHT")
	macrobutt:SetWidth(60) macrobutt:SetHeight(18)
	macrobutt.tiptext = "Click to generate a macro, or pick it up if already generated."
	macrobutt:SetText("Macro")
	macrobutt:SetScript("OnClick", Cork.GenerateMacro)


	local rows, corknames, anchor = {}, {}
	local NUMROWS = math.floor((group:GetHeight()-EDGEGAP+ROWGAP + 2) / (ROWHEIGHT+ROWGAP))
	for name in pairs(Cork.corks) do table.insert(corknames, (name:gsub("Cork ", ""))) end
	table.sort(corknames)
	local function OnClick(self)
		Cork.dbpc[self.name.."-enabled"] = not Cork.dbpc[self.name.."-enabled"]
		PlaySound(Cork.dbpc[self.name.."-enabled"] and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
		Cork.corks["Cork ".. self.name]:Scan()
	end
	for i=1,NUMROWS do
		local row = CreateFrame("Button", nil, group)
		if anchor then row:SetPoint("TOP", anchor , "BOTTOM", 0, -ROWGAP)
		else row:SetPoint("TOP", 0, -EDGEGAP/2) end
		row:SetPoint("LEFT", EDGEGAP/2, 0)
		row:SetPoint("RIGHT", -EDGEGAP/2 - 22, 0)
		row:SetHeight(ROWHEIGHT)
		anchor = row
		rows[i] = row


		local check = CreateFrame("CheckButton", nil, row)
		check:SetWidth(ROWHEIGHT+4)
		check:SetHeight(ROWHEIGHT+4)
		check:SetPoint("LEFT")
		check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
		check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
		check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
		check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
		check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		check:SetHitRectInsets(0, -100, 0, 0)
		check:SetScript("OnClick", OnClick)
		row.check = check


		local title = row:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
		title:SetPoint("LEFT", check, "RIGHT", 4, 0)
		row.title = title
	end


	local scrollbar = LibStub("tekKonfig-Scroll").new(group, 6, #rows/2)
	local f = scrollbar:GetScript("OnValueChanged")
	scrollbar:SetScript("OnValueChanged", function(self, value, ...)
		local offset = math.floor(value)

		for _,name in pairs(corknames) do
			local configframe = Cork.corks["Cork "..name].configframe
			if configframe then configframe:Hide() end
		end

		for i,row in pairs(rows) do
			local name = corknames[i + offset]
			if name then
				row:Show()
				row.check.name = name
				row.title:SetText(name)
				row.check:SetChecked(Cork.dbpc[name.."-enabled"])

				local configframe = Cork.corks["Cork "..name].configframe
				if configframe then
					configframe:SetPoint("RIGHT", row)
					configframe:SetFrameLevel(row:GetFrameLevel() + 1)
					configframe:Show()
				end
			else
				row:Hide()
				row.check.name = nil
				row.title:SetText()
				row.check:SetChecked(false)
			end
		end
		return f(self, value, ...)
	end)
	scrollbar:SetMinMaxValues(0, math.max(0, #corknames-#rows))
	scrollbar:SetValue(0)

	group:EnableMouseWheel()
	group:SetScript("OnMouseWheel", function(self, val) scrollbar:SetValue(scrollbar:GetValue() - val*#rows/2) end)


	local function Update(self)
		showanchor:SetChecked(Cork.db.showanchor)
		showbg:SetChecked(Cork.db.showbg)
		showunit:SetChecked(Cork.db.showunit)
		bindwheel:SetChecked(Cork.db.bindwheel)
		if castonpets then castonpets:SetChecked(Cork.dbpc.castonpets) end
		if groupthresh then groupthresh:SetValue(Cork.dbpc.multithreshold) end
	end

	frame:SetScript("OnShow", Update)
	Update(frame)
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
