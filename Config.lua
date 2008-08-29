

local Cork = Cork

local GAP = 8
local tekcheck = LibStub("tekKonfig-Checkbox")


local frame = CreateFrame("Frame", nil, UIParent)
Cork.config = frame
frame.name = "Cork"
frame:Hide()

frame:SetScript("OnShow", function()
	local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 16, 2, 4

	local title, subtitle = LibStub("tekKonfig-Heading").new(frame, "Cork", "These settings are saved on a per-char basis.")

	local showanchor = tekcheck.new(frame, nil, "Show anchor", "TOPLEFT", subtitle, "BOTTOMLEFT", -2, -GAP)
	showanchor.tiptext = "Toggle the tooltip anchor."
	local checksound = showanchor:GetScript("OnClick")
	showanchor:SetScript("OnClick", function(self)
		checksound(self)
		Cork.db.showanchor = not Cork.db.showanchor
		if Cork.db.showanchor then Cork.anchor:Show() else Cork.anchor:Hide() end
	end)


	local showunit = tekcheck.new(frame, nil, "Show unitID", "TOPLEFT", showanchor, "BOTTOMLEFT", 0, -GAP)
	showunit.tiptext = "Show unitID (target, party1, raidpet5) in tooltip."
	showunit:SetScript("OnClick", function(self)
		checksound(self)
		Cork.db.showunit = not Cork.db.showunit
		Cork.Update()
	end)


	local tooltiplimit, tooltiplimittext, ttlcontainer = LibStub("tekKonfig-Slider").new(frame, "Tooltip Limit: " .. Cork.dbpc.tooltiplimit, 0, 40, "TOP", showanchor, "TOP")
	ttlcontainer:SetPoint("LEFT", frame, "CENTER", GAP*5/2, 0)
	tooltiplimit.tiptext = "The number of units to show in the Cork tooltip."
	tooltiplimit:SetValueStep(1)
	tooltiplimit:SetValue(Cork.dbpc.tooltiplimit)
	tooltiplimit:SetScript("OnValueChanged", function(self, newvalue)
		Cork.dbpc.tooltiplimit = newvalue
		tooltiplimittext:SetText("Tooltip Limit: " .. newvalue)
	end)


	local castonpets, groupthresh, groupthreshtext, groupthreshcont
	if Cork.hasgroupspell then
		groupthresh, groupthreshtext, groupthreshcont = LibStub("tekKonfig-Slider").new(frame, "Group Threshold: ".. Cork.dbpc.multithreshold, 1, 6, "TOPLEFT", ttlcontainer, "BOTTOMLEFT") --, GAP*2, -GAP)
		groupthresh.tiptext = "Minimum number of needy players in a group required to cast multi-target spells.  Setting this to six will disable the automatic use of group spells."
		groupthresh:SetValueStep(1)
		groupthresh:SetScript("OnValueChanged", function(self, newvalue)
			Cork.dbpc.multithreshold = newvalue
			groupthreshtext:SetText("Group Threshold: ".. newvalue)
		end)

--~ 		castonpets = tekcheck.new(frame, nil, "Cast on group pets", "TOPLEFT", groupthreshcont, "BOTTOMLEFT", -GAP*2, 0)
		castonpets = tekcheck.new(frame, nil, "Cast on group pets", "TOPLEFT", showunit, "BOTTOMLEFT", 0, -GAP)
		castonpets.tiptext = "Pets need buffs too!  When disabled you can still cast on a pet by targetting it directly."
		castonpets:SetScript("OnClick", function(self)
			checksound(self)
			Cork.dbpc.castonpets = not Cork.dbpc.castonpets
			for name,dataobj in pairs(Cork.corks) do dataobj:Scan() end
		end)
	end


	local group = LibStub("tekKonfig-Group").new(frame, "Modules", "TOP", castonpets or showunit, "BOTTOM", 0, -27)
	group:SetPoint("LEFT", EDGEGAP, 0)
	group:SetPoint("BOTTOMRIGHT", -EDGEGAP, EDGEGAP)


	local macrobutt = LibStub("tekKonfig-Button").new_small(frame, "BOTTOMRIGHT", group, "TOPRIGHT")
	macrobutt:SetWidth(60) macrobutt:SetHeight(18)
	macrobutt.tiptext = "Click to generate a macro, or pick it up if already generated."
	macrobutt:SetText("Macro")
	macrobutt:SetScript("OnClick", Cork.GenerateMacro)


	local rows, corknames, anchor = {}, {}
	for name in pairs(Cork.corks) do table.insert(corknames, (name:gsub("Cork ", ""))) end
	table.sort(corknames)
	local function OnClick(self)
		Cork.dbpc[self.name.."-enabled"] = not Cork.dbpc[self.name.."-enabled"]
		PlaySound(Cork.dbpc[self.name.."-enabled"] and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
		Cork.corks["Cork ".. self.name]:Scan()
	end
	for i=1,math.floor((group:GetHeight() - EDGEGAP)/(ROWHEIGHT + ROWGAP)) do
		local row = CreateFrame("Button", nil, group)
		if anchor then row:SetPoint("TOP", anchor , "BOTTOM", 0, -ROWGAP)
		else row:SetPoint("TOP", 0, -EDGEGAP/2) end
		row:SetPoint("LEFT", EDGEGAP/2, 0)
		row:SetPoint("RIGHT", -EDGEGAP/2, 0)
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
		check:SetScript("OnClick", OnClick)
		row.check = check


		local title = row:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
		title:SetPoint("LEFT", check, "RIGHT", 4, 0)
		row.title = title
	end


	local function Update(self)
		showanchor:SetChecked(Cork.db.showanchor)
		showunit:SetChecked(Cork.db.showunit)
		if castonpets then castonpets:SetChecked(Cork.dbpc.castonpets) end
		if groupthresh then groupthresh:SetValue(Cork.dbpc.multithreshold) end
		for i,row in pairs(rows) do
			local name = corknames[i]
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
	end

	frame:SetScript("OnShow", Update)
	frame:SetScript("OnHide", function() for name,dataobj in pairs(Cork.corks) do if dataobj.configframe then dataobj.configframe:Hide() end end end)
	Update(frame)
end)

InterfaceOptions_AddCategory(frame)


----------------------------
--      LDB Launcher      --
----------------------------

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:GetDataObjectByName("CorkLauncher") or ldb:NewDataObject("CorkLauncher", {type = "launcher", icon = "Interface\\Icons\\INV_Drink_11", tocname = "Cork"})
dataobj.OnClick = function() InterfaceOptionsFrame_OpenToFrame(frame) end

----------------------------
--       Key Binding      --
----------------------------
setglobal("BINDING_HEADER_CORK", "Cork")
setglobal("BINDING_NAME_CLICK CorkFrame:LeftButton", "Click the Cork frame")
