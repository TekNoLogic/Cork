
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

Cork = {petmappings = {player = "pet"}}
local corks, blist = {}, {CorkIt = true, type = true}
local defaults, db = {point = "TOP", x = 0, y = -100, showanchor = true}
local tooltip, anchor, Update

for i=1,4 do Cork.petmappings["party"..i] = "partypet"..i end
for i=1,40 do Cork.petmappings["raid"..i] = "raidpet"..i end


------------------------------
--      Initialization      --
------------------------------

ae.RegisterEvent("Cork", "ADDON_LOADED", function(event, addon)
	if addon:lower() ~= "cork" then return end

	CorkDB = setmetatable(CorkDB or {}, {__index = defaults})
	db = CorkDB

	anchor:SetPoint(db.point, db.x, db.y)
	if not db.showanchor then anchor:Hide() end
	Update()

	ae.UnregisterEvent("Cork", "ADDON_LOADED")
end)


ae.RegisterEvent("Cork", "PLAYER_LOGOUT", function() for i,v in pairs(defaults) do if db[i] == v then db[i] = nil end end end)


------------------------------
--      Tooltip anchor      --
------------------------------

anchor = CreateFrame("Button", nil, UIParent)
anchor:SetHeight(24)

anchor:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5}, tile = true, tileSize = 16})
anchor:SetBackdropColor(0.09, 0.09, 0.19, 0.5)
anchor:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)

local text = anchor:CreateFontString(nil, nil, "GameFontNormalSmall")
text:SetPoint("CENTER")
text:SetText("Cork")
anchor:SetWidth(text:GetStringWidth() + 8)


anchor:SetMovable(true)
anchor:RegisterForDrag("LeftButton")

anchor:SetScript("OnDragStart", function(self)
	tooltip:Hide()
	self:StartMoving()
end)


anchor:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	db.point, db.x, db.y = "BOTTOMLEFT", self:GetCenter()
	Update()
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


function Update(event, name, attr, value, dataobj)
	if blist[attr] then return end

	tooltip:ClearLines()
	tooltip:SetOwner(anchor, "ANCHOR_NONE")
	tooltip:SetPoint(GetTipAnchor(anchor))

	for name,dataobj in pairs(corks) do
		for i,v in ldb:pairs(dataobj) do
			if not blist[i] then
				tooltip:AddLine(v)
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
	ldb.RegisterCallback("Corker", "LibDataBroker_AttributeChanged_"..name, Update)
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
	for name,dataobj in pairs(corks) do if dataobj.CorkIt and dataobj:CorkIt(self) then return end end
end)


secureframe:SetScript("PostClick", function()
	if InCombatLockdown() then return end
	secureframe:SetManyAttributes("type1", ATTRIBUTE_NOOP, "bag1", nil, "slot1", nil, "item1", nil, "spell", nil, "unit", nil)
end)


--------------------------------
--      Shared functions      --
--------------------------------

function Cork.SpellCastableOnUnit(spell, unit)
	if blist[i] then return end
	return UnitExists(unit) and UnitCanAssist("player", unit) and not UnitIsDeadOrGhost(unit) and IsSpellInRange(spell, unit)
end

function Cork.IconLine(icon, text) return "|T"..icon..":14|t "..text end
