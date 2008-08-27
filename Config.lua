

local Cork = Cork

local GAP = 8
local tekcheck = LibStub("tekKonfig-Checkbox")


local frame = CreateFrame("Frame", nil, UIParent)
Cork.config = frame
frame.name = "Cork"
frame:Hide()

frame:SetScript("OnShow", function()
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


	if Cork.hasgroupspell then
		local castonpets = tekcheck.new(frame, nil, "Cast on group pets", "TOP", showanchor, "TOP")
		castonpets:SetPoint("LEFT", frame, "CENTER", GAP/2, 0)
		castonpets.tiptext = "Pets need buffs too!  When disabled you can still cast on a pet by targetting it directly."
		castonpets:SetScript("OnClick", function(self)
			checksound(self)
			Cork.dbpc.castonpets = not Cork.dbpc.castonpets
			for name,dataobj in pairs(Cork.corks) do dataobj:Scan() end
		end)
	end


	local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 16, 2, 4
	local rows, corknames, anchor = {}, {}
	for name in pairs(Cork.corks) do table.insert(corknames, (name:gsub("Cork ", ""))) end
	table.sort(corknames)
	local function OnClick(self)
		Cork.dbpc[self.name.."-enabled"] = not Cork.dbpc[self.name.."-enabled"]
		PlaySound(Cork.dbpc[self.name.."-enabled"] and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
		Cork.corks["Cork ".. self.name]:Scan()
	end
	for i=1,math.floor((305-22-8-24)/(ROWHEIGHT + ROWGAP)) do
		local row = CreateFrame("Button", nil, frame)
		if not anchor then row:SetPoint("TOP", showunit, "BOTTOM", 0, -16)
		else row:SetPoint("TOP", anchor, "BOTTOM", 0, -ROWGAP) end
		row:SetPoint("LEFT", EDGEGAP*2, 0)
		row:SetPoint("RIGHT", -EDGEGAP, 0)
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
		for i,row in pairs(rows) do
			local name = corknames[i]
			if name then
				row:Show()
				row.check.name = name
				row.title:SetText(name)
				row.check:SetChecked(Cork.dbpc[name.."-enabled"])
			else
				row:Hide()
				row.check.name = nil
				row.title:SetText()
				row.check:SetChecked(false)
			end
		end
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
dataobj.OnClick = function() InterfaceOptionsFrame_OpenToFrame(frame) end
