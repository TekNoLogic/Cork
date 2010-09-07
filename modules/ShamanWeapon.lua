
local myname, Cork = ...
if Cork.MYCLASS ~= "SHAMAN" then return end


local myname, Cork = ...
local UnitAura = Cork.UnitAura or UnitAura
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
local f, elapsed = CreateFrame("Frame"), 0
local enchantable_offhands = {INVTYPE_WEAPON = true, }


local MAINHAND, OFFHAND = GetInventorySlotInfo("MainHandSlot"), GetInventorySlotInfo("SecondaryHandSlot")
local IconLine = Cork.IconLine

local spellidlist = Cork.IHASCAT and {8024, 8033, 8232, 51730, 8017} or {8017, 8024, 8033, 8232, 51730}
local buffnames, icons, known = {}, {}
for _,id in pairs(spellidlist) do
	local spellname, _, icon = GetSpellInfo(id)
	buffnames[id], icons[spellname] =  spellname, icon
end
Cork.defaultspc["Temp Enchant-mainspell"], Cork.defaultspc["Temp Enchant-offspell"] = buffnames[spellidlist[1]], buffnames[spellidlist[1]]

local function RefreshKnownSpells() -- Refresh in case the player has learned this since login
	for buff in pairs(icons) do if known[buff] == nil then known[buff] = GetSpellInfo(buff) end end
end

local dataobj = ldb:NewDataObject("Cork Temp Enchant", {type = "cork"})

function dataobj:Init()
	known = {}
	RefreshKnownSpells()
	Cork.defaultspc["Temp Enchant-enabled"] = not not next(known)
end
function dataobj:Scan() if Cork.dbpc["Temp Enchant-enabled"] then f:Show() else f:Hide(); dataobj.mainhand, dataobj.offhand = nil end end


function dataobj:CorkIt(frame)
	RefreshKnownSpells()
	if self.mainhand then return frame:SetManyAttributes("type1", "spell", "spell", Cork.dbpc["Temp Enchant-mainspell"]) end
	if self.offhand then return frame:SetManyAttributes("type1", "spell", "spell", Cork.dbpc["Temp Enchant-offspell"]) end
end


local offhands = {INVTYPE_WEAPON = true, INVTYPE_WEAPONOFFHAND = true}
f:SetScript("OnUpdate", function(self, elap)
	elapsed = elapsed + elap
	if elapsed < 0.5 then return end

	elapsed = 0

	local zzz = IsResting()
	local main, _, _, offhand = GetWeaponEnchantInfo()
	local icon = icons[Cork.dbpc["Temp Enchant-mainspell"]]
	dataobj.mainhand = not main and not zzz and GetInventoryItemLink("player", MAINHAND) and IconLine(icon, INVTYPE_WEAPONMAINHAND)

	local offlink = GetInventoryItemLink("player", OFFHAND)
	local offweapon = offlink and offhands[select(9, GetItemInfo(offlink))]
	local icon = icons[Cork.dbpc["Temp Enchant-offspell"]]
	dataobj.offhand = not offhand and not zzz and offweapon and IconLine(icon, INVTYPE_WEAPONOFFHAND)
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
		Cork.dbpc["Temp Enchant-"..(self.isOffhand and "offspell" or "mainspell")] = self.buff
		for buff,butt in pairs(self.isOffhand and buffbuttons2 or buffbuttons) do butt:SetChecked(butt == self) end
		dataobj:Scan()
	end

	local function OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(GetSpellLink(self.buff))
	end
	local function OnLeave() GameTooltip:Hide() end


	local function MakeButt(buff, isOffhand)
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

		butt.buff, butt.isOffhand = buff, isOffhand
		butt:SetScript("OnClick", OnClick)
		butt:SetScript("OnEnter", OnEnter)
		butt:SetScript("OnLeave", OnLeave)

		return butt
	end

	local lasticon
	for _,id in ipairs(spellidlist) do
		local buff = buffnames[id]
		local butt = MakeButt(buff)
		if lasticon then lasticon:SetPoint("RIGHT", butt, "LEFT", -ROWGAP, 0) end
		buffbuttons[buff], lasticon = butt, butt
	end
	for i,id in ipairs(spellidlist) do
		local buff = buffnames[id]
		local butt = MakeButt(buff, true)
		lasticon:SetPoint("RIGHT", butt, "LEFT", i == 1 and -ROWHEIGHT or -ROWGAP, 0)
		buffbuttons2[buff], lasticon = butt, butt
	end
	lasticon:SetPoint("RIGHT", 0, 0)

	local function Update(self)
		RefreshKnownSpells()

		for buff,butt in pairs(buffbuttons) do
			butt:SetChecked(Cork.dbpc["Temp Enchant-mainspell"] == buff)
			if known[buff] then
				butt:Enable()
				butt.icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				butt:Disable()
				butt.icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end

		for buff,butt in pairs(buffbuttons2) do
			butt:SetChecked(Cork.dbpc["Temp Enchant-offspell"] == buff)
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
