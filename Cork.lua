
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

Cork = {petmappings = {player = "pet"}, defaultspc = {castonpets = false, multithreshold = 2, tooltiplimit = 10}, corks = {}, petunits = {pet = true}, keyblist = {CorkIt = true, type = true, Scan = true, Init = true, configframe = true}}
local corks = Cork.corks
local defaults = {point = "TOP", x = 0, y = -100, showanchor = true, showunit = false, bindwheel = false}
local tooltip, anchor

for i=1,4 do Cork.petmappings["party"..i], Cork.petunits["partypet"..i] = "partypet"..i, true end
for i=1,40 do Cork.petmappings["raid"..i], Cork.petunits["raidpet"..i] = "raidpet"..i, true end


----------------------------
--      Localization      --
----------------------------

Cork.classnames = {
	["WARLOCK"] = "Warlock",
	["WARRIOR"] = "Warrior",
	["HUNTER"] = "Hunter",
	["MAGE"] = "Mage",
	["PRIEST"] = "Priest",
	["DRUID"] = "Druid",
	["PALADIN"] = "Paladin",
	["SHAMAN"] = "Shaman",
	["ROGUE"] = "Rogue",
	["DEATHKNIGHT"] = "Death Knight",
}
if not IS_WRATH_BUILD then Cork.classnames.DEATHKNIGHT = nil end

Cork.colors = {}
for token in pairs(Cork.classnames) do
	local c = RAID_CLASS_COLORS[token]
	Cork.colors[token] = string.format("%02x%02x%02x", c.r*255, c.g*255, c.b*255)
end


------------------------------
--      Initialization      --
------------------------------

ae.RegisterEvent("Cork", "ADDON_LOADED", function(event, addon)
	if addon:lower() ~= "cork" then return end

	CorkDB, CorkDBPC = setmetatable(CorkDB or {}, {__index = defaults}), setmetatable(CorkDBPC or {}, {__index = Cork.defaultspc})
	Cork.db, Cork.dbpc = CorkDB, CorkDBPC

	anchor:SetPoint(Cork.db.point, Cork.db.x, Cork.db.y)
	if not Cork.db.showanchor then anchor:Hide() end

	LibStub("tekKonfig-AboutPanel").new("Cork", "Cork")

	ae.UnregisterEvent("Cork", "ADDON_LOADED")
end)


ae.RegisterEvent("Cork", "PLAYER_LOGIN", function()
	for name,dataobj in pairs(corks) do
		if dataobj.Init then
			dataobj:Init()
			dataobj.Init = nil
		end
	end

	for name,dataobj in pairs(corks) do dataobj:Scan() end

	ae.UnregisterEvent("Cork", "PLAYER_LOGIN")
end)


ae.RegisterEvent("Cork", "PLAYER_LOGOUT", function()
	for i,v in pairs(defaults) do if Cork.db[i] == v then Cork.db[i] = nil end end
	for i,v in pairs(Cork.defaultspc) do if Cork.dbpc[i] == v then Cork.dbpc[i] = nil end end
end)


------------------------------
--      Tooltip anchor      --
------------------------------

anchor = CreateFrame("Button", nil, UIParent)
anchor:SetHeight(24)
Cork.anchor = anchor

anchor:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5}, tile = true, tileSize = 16})
anchor:SetBackdropColor(0.09, 0.09, 0.19, 0.5)
anchor:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

local text = anchor:CreateFontString(nil, nil, "GameFontNormalSmall")
text:SetPoint("CENTER")
text:SetText("Cork")
anchor:SetWidth(text:GetStringWidth() + 8)


anchor:SetMovable(true)
anchor:RegisterForDrag("LeftButton")

anchor:SetScript("OnClick", function(self) InterfaceOptionsFrame_OpenToFrame(Cork.config) end)


anchor:SetScript("OnDragStart", function(self)
	tooltip:Hide()
	self:StartMoving()
end)


anchor:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	Cork.db.point, Cork.db.x, Cork.db.y = "BOTTOMLEFT", self:GetCenter()
	Cork.Update()
end)


-----------------------
--      Tooltip      --
-----------------------

tooltip = CreateFrame("GameTooltip", "Corkboard", UIParent, "GameTooltipTemplate")
CorkboardTextLeft1:SetFontObject(GameTooltipText)
CorkboardTextRight1:SetFontObject(GameTooltipText)


local function GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", frame, "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end


function Cork.Update(event, name, attr, value, dataobj)
	if Cork.keyblist[attr] then return end

	tooltip:ClearLines()
	tooltip:SetOwner(anchor, "ANCHOR_NONE")
	tooltip:SetPoint(GetTipAnchor(anchor))

	local count = 0
	for name,dataobj in pairs(corks) do
		for i,v in ldb:pairs(dataobj) do
			if not Cork.keyblist[i] and count < Cork.dbpc.tooltiplimit then
				if Cork.db.showunit then tooltip:AddDoubleLine(v, i) else tooltip:AddLine(v) end
				count = count + 1
			end
		end
	end

	if tooltip:NumLines() > 0 then tooltip:Show() end
end


-------------------------
--      LDB stuff      --
-------------------------

local function NewDataobject(event, name, dataobj)
	if dataobj.type ~= "cork" then return end
	corks[name] = dataobj
	ldb.RegisterCallback("Corker", "LibDataBroker_AttributeChanged_"..name, Cork.Update)
end

ldb.RegisterCallback("Corker", "LibDataBroker_DataObjectCreated", NewDataobject)


----------------------------
--      Secure frame      --
----------------------------

local secureframe = CreateFrame("Button", "CorkFrame", UIParent, "SecureActionButtonTemplate")

secureframe.SetManyAttributes = function(self, ...)
	for i=1,select("#", ...),2 do
		local att,val = select(i, ...)
		if not att then return end
		self:SetAttribute(att,val)
	end
	return true
end


secureframe:SetScript("PreClick", function(self)
	if InCombatLockdown() then return end
	for name,dataobj in pairs(corks) do if dataobj.CorkIt and dataobj.player and dataobj:CorkIt(self) then return end end
	for name,dataobj in pairs(corks) do if dataobj.CorkIt and not dataobj.player and dataobj:CorkIt(self, true) then return end end
	for name,dataobj in pairs(corks) do if dataobj.CorkIt and not dataobj.player and dataobj:CorkIt(self) then return end end
end)


secureframe:SetScript("PostClick", function()
	if InCombatLockdown() then return end
	secureframe:SetManyAttributes("type1", ATTRIBUTE_NOOP, "bag1", nil, "slot1", nil, "item1", nil, "spell", nil, "unit", nil)
end)


--------------------------------
--      Shared functions      --
--------------------------------

function Cork.SpellCastableOnUnit(spell, unit)
	if Cork.keyblist[i] then return end
	return UnitExists(unit) and UnitCanAssist("player", unit) and not UnitIsDeadOrGhost(unit) and IsSpellInRange(spell, unit)
end

function Cork.IconLine(icon, text, token)
	return "|T"..icon..":24|t ".. (token and ("|cff".. Cork.colors[token]) or "").. text
end
