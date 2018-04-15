
local myname, Cork = ...
if Cork.MYCLASS ~= "HUNTER" then return end
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
local GetSpellInfo = GetSpellInfo
local IconLine = Cork.IconLine

local spellidlist = {883,83242,83243,83244,83245,2641}
local dismissSpell, _, dismissIcon = GetSpellInfo(2641)
local reviveSpell, _, reviveIcon = GetSpellInfo(982)
local loneWolfSpell = GetSpellInfo(164273)

local known, names = {}, {}

for _, id in ipairs(spellidlist) do
	names[id] = GetSpellInfo(id)
end

local dataobj = ldb:NewDataObject("Cork Hunter Pet", {
	type = "cork"
})

local function RefreshKnownPets()
	for id, spell in pairs(names) do
		known[spell] = GetSpellInfo(spell)
	end
end

function dataobj:Init()
	RefreshKnownPets()
	Cork.defaultspc["Hunter Pet-spell"] = names[spellidlist[1]]
	Cork.defaultspc["Hunter Pet-enabled"] = next(known) ~= nil
end

local function DoTest()
	if UnitBuff("player", loneWolfSpell) then
		return
	end

	if UnitExists("pet") and UnitIsDead("pet") then
		return reviveSpell
	end

	local spell = Cork.dbpc["Hunter Pet-spell"]

	if spell == dismissSpell then
		if UnitExists("pet") then
			return dismissSpell
		end
		return
	end

	if not UnitExists("pet") then
		return spell
	end
end

function dataobj:Test()
	if Cork.dbpc["Hunter Pet-enabled"] and not (IsResting() and not Cork.db.debug) and not UnitIsUnit('pet', 'vehicle') then
		local spell = DoTest()
		if spell then
			return IconLine(select(3, GetSpellInfo(spell)), spell)
		end
	end
end

function dataobj:Scan(event, unit)
	if not unit or unit == "player" then self.player = self:Test() end
end

function dataobj:CorkIt(frame)
	RefreshKnownPets()
	if self.player then return frame:SetManyAttributes("type1", "spell", "spell", DoTest()) end
end

ae.RegisterEvent(dataobj, "UNIT_PET", "Scan")
ae.RegisterEvent(dataobj, "UNIT_AURA", "Scan")
ae.RegisterEvent(dataobj, "PLAYER_UPDATE_RESTING", "Scan")

-- PET_ATTACK_STOP happens when the pet dies
ae.RegisterEvent(dataobj, "PET_ATTACK_STOP", "Scan")

----------------------
--      Config      --
----------------------

local frame = CreateFrame("Frame", nil, Cork.config)
frame:SetWidth(1) frame:SetHeight(1)
dataobj.configframe = frame
frame:Hide()

frame:SetScript("OnShow", function()
	local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 18, 2, 4
	local spellbuttons = {}

	local function OnClick(self)
		Cork.dbpc["Hunter Pet-spell"] = self.spell
		for spell,butt in pairs(spellbuttons) do butt:SetChecked(butt == self) end
		dataobj:Scan()
	end

	local function OnEnter(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(GetSpellLink(self.spellid))
	end
	local function OnLeave() GameTooltip:Hide() end


	local lasticon
	for _,id in ipairs(spellidlist) do
		local spell = names[id]

		local butt = CreateFrame("CheckButton", nil, frame)
		butt:SetWidth(ROWHEIGHT) butt:SetHeight(ROWHEIGHT)

		local tex = butt:CreateTexture(nil, "BACKGROUND")
		tex:SetAllPoints()
		tex:SetTexture((select(3, GetSpellInfo(spell))))
		tex:SetTexCoord(4/48, 44/48, 4/48, 44/48)
		butt.icon = tex

		butt:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
		butt:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
		butt:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")

		if lasticon then lasticon:SetPoint("RIGHT", butt, "LEFT", -ROWGAP, 0) end

		butt.spell = spell
		butt.spellid = id
		butt:SetScript("OnClick", OnClick)
		butt:SetScript("OnEnter", OnEnter)
		butt:SetScript("OnLeave", OnLeave)
		butt:SetMotionScriptsWhileDisabled(true)

		spellbuttons[spell], lasticon = butt, butt
	end
	lasticon:SetPoint("RIGHT", 0, 0)

	local function Update(self)
		RefreshKnownPets()

		for spell,butt in pairs(spellbuttons) do
			butt:SetChecked(Cork.dbpc["Hunter Pet-spell"] == spell)
			if known[spell] then
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
