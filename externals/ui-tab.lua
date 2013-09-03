
local myname, ns = ...


local function activatetab(self)
	self.left:ClearAllPoints()
	self.left:SetPoint("TOPLEFT")
	self.left:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
	self.middle:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
	self.right:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-ActiveTab")
	self:Disable()
end


local function deactivatetab(self)
	self.left:ClearAllPoints()
	self.left:SetPoint("BOTTOMLEFT", 0, 2)
	self.left:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	self.middle:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	self.right:SetTexture("Interface\\OptionsFrame\\UI-OptionsFrame-InActiveTab")
	self:Enable()
end


local function SetTextHelper(self, ...)
	self:SetWidth(40 + self:GetFontString():GetStringWidth())
	return ...
end


local function NewSetText(self, ...)
	return SetTextHelper(self, self.OrigSetText(self, ...))
end


-- Creates a tab.
-- All args optional but parent is highly recommended
function ns.NewTab(parent, text, ...)
	local tab = CreateFrame("Button", nil, parent)
	tab:SetHeight(24)
	if select(1, ...) then tab:SetPoint(...) end
	tab:SetFrameLevel(tab:GetFrameLevel() + 4)

	tab.left = tab:CreateTexture(nil, "BORDER")
	tab.left:SetWidth(20) tab.left:SetHeight(24)
	tab.left:SetTexCoord(0, 0.15625, 0, 1)

	tab.right = tab:CreateTexture(nil, "BORDER")
	tab.right:SetWidth(20) tab.right:SetHeight(24)
	tab.right:SetPoint("TOP", tab.left)
	tab.right:SetPoint("RIGHT", tab)
	tab.right:SetTexCoord(0.84375, 1, 0, 1)

	tab.middle = tab:CreateTexture(nil, "BORDER")
	tab.middle:SetHeight(24)
	tab.middle:SetPoint("LEFT", tab.left, "RIGHT")
	tab.middle:SetPoint("RIGHT", tab.right, "Left")
	tab.middle:SetTexCoord(0.15625, 0.84375, 0, 1)

	tab:SetHighlightTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight", "ADD")
	local hilite = tab:GetHighlightTexture()
	hilite:ClearAllPoints()
	hilite:SetPoint("LEFT", 10, -4)
	hilite:SetPoint("RIGHT", -10, -4)

	tab:SetDisabledFontObject(GameFontHighlightSmall)
	tab:SetHighlightFontObject(GameFontHighlightSmall)
	tab:SetNormalFontObject(GameFontNormalSmall)
	tab.OrigSetText = tab.SetText
	tab.SetText = NewSetText
	if text then tab:SetText(text) end

	tab.Activate, tab.Deactivate = activatetab, deactivatetab
	tab:Activate()

	return tab
end

