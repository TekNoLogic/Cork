

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
	showanchor:SetScript("OnClick", function(self) checksound(self); TourGuide.db.char.trackquests = not TourGuide.db.char.trackquests end)
	showanchor:SetScript("OnClick", function(self)
		checksound(self)
		Cork.db.showanchor = not Cork.db.showanchor
		if Cork.db.showanchor then Cork.anchor:Show() else Cork.anchor:Hide() end
	end)


	local function Update(self)
		showanchor:SetChecked(Cork.db.showanchor)
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
