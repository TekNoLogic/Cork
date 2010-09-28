
local myname, Cork = ...
if Cork.MYCLASS ~= "WARLOCK" or Cork.IHASCAT then return end


local myname, Cork = ...
local UnitAura = Cork.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
local f, elapsed = CreateFrame("Frame"), 0


local MAINHAND = GetInventorySlotInfo("MainHandSlot")
local IconLine = Cork.IconLine

local fstone = GetSpellInfo(6366)
local spellidlist = {6366, 2362}
local firestones, spellstones = {41174, 41173, 40773, 41172, 41171, 41169, 41170}, {41196, 41195, 41194, 41193, 41192, 41191}
local buffnames, icons, known = {}, {}
for _,id in pairs(spellidlist) do
	local spellname, _, icon = GetSpellInfo(id)
	buffnames[id], icons[spellname] =  spellname, icon
end
Cork.defaultspc["Temp Enchant-spell"] = buffnames[spellidlist[1]]

local function RefreshKnownSpells() -- Refresh in case the player has learned this since login
	for buff in pairs(icons) do if known[buff] == nil then known[buff] = GetSpellInfo(buff) end end
end

local dataobj = ldb:NewDataObject("Cork Temp Enchant", {type = "cork"})

function dataobj:Init()
	known = {}
	RefreshKnownSpells()
	Cork.defaultspc["Temp Enchant-enabled"] = not not next(known)
end
function dataobj:Scan() if Cork.dbpc["Temp Enchant-enabled"] then f:Show() else f:Hide(); dataobj.mainhand = nil end end


function dataobj:CorkIt(frame)
	RefreshKnownSpells()
	if not self.mainhand then return end
	local stones = Cork.dbpc["Temp Enchant-spell"] == fstone and firestones or spellstones
	for _,id in ipairs(stones) do if (GetItemCount(id) or 0) > 0 then return frame:SetManyAttributes("type1", "macro", "macrotext1", "/use item:"..id.."\n/use 16") end end
	return frame:SetManyAttributes("type1", "spell", "spell", Cork.dbpc["Temp Enchant-spell"])
end


f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < 0.5 then return end

	elapsed = 0

	local main = GetWeaponEnchantInfo()
	local icon = icons[Cork.dbpc["Temp Enchant-spell"]]
	dataobj.mainhand = not main and not (IsResting() and not Cork.db.debug) and GetInventoryItemLink("player", MAINHAND) and IconLine(icon, INVTYPE_WEAPONMAINHAND)
end)


----------------------
--      Config      --
----------------------

local frame = CreateFrame("Frame", nil, Cork.config)
frame:SetWidth(1) frame:SetHeight(1)
dataobj.configframe = frame
frame:Hide()

frame:SetScript("OnShow", function()
	local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 18, 2, 4
	local buffbuttons, buffbuttons2 = {}, {}

	local function OnClick(self)
		Cork.dbpc["Temp Enchant-spell"] = self.buff
		for buff,butt in pairs(buffbuttons) do butt:SetChecked(butt == self) end
		dataobj:Scan()
	end

	local function OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.buff:gsub("Create ", ""), nil, nil, nil, nil, true)
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

		butt.buff = buff
		butt:SetScript("OnClick", OnClick)
		butt:SetScript("OnEnter", OnEnter)
		butt:SetScript("OnLeave", OnLeave)

		if lasticon then lasticon:SetPoint("RIGHT", butt, "LEFT", -ROWGAP, 0) end
		buffbuttons[buff], lasticon = butt, butt
	end
	lasticon:SetPoint("RIGHT", 0, 0)

	local function Update(self)
		RefreshKnownSpells()

		for buff,butt in pairs(buffbuttons) do
			butt:SetChecked(Cork.dbpc["Temp Enchant-spell"] == buff)
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
