
local myname, Cork = ...
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")
local _

_, Cork.MYCLASS = UnitClass("player")

Cork.corks, Cork.db, Cork.dbpc, Cork.defaultspc = {}, {}, {}, {}
Cork.sortedcorks = {}

local defaults = {point = "TOP", x = 0, y = -100, showanchor = true, debug = false, bindwheel = false}
local tooltip, anchor

for i=1,MAX_BOSS_FRAMES do Cork.keyblist["boss"..i] = true end


------------------------------
--      Initialization      --
------------------------------

ae.RegisterEvent("Cork", "ADDON_LOADED", function(event, addon)
	if addon:lower() ~= "cork" then return end

	CorkDB = setmetatable(CorkDB or {}, {__index = defaults})
	CorkDBPC = CorkDBPC or {{},{},{},{}}
	if not CorkDBPC[1] then CorkDBPC = {CorkDBPC, {}, {}, {}} end
	for _, i in ipairs({2,3,4}) do
		if not CorkDBPC[i] then CorkDBPC[i] = {} end
	end
	Cork.db = CorkDB

	anchor:SetPoint(Cork.db.point, Cork.db.x, Cork.db.y)
	if not Cork.db.showanchor then anchor:Hide() end

	ae.UnregisterEvent("Cork", "ADDON_LOADED")
end)


local meta = {__index = Cork.defaultspc}
ae.RegisterEvent("Cork", "PLAYER_LOGIN", function()
	local lastspec = GetSpecialization()
	Cork.dbpc = setmetatable(CorkDBPC[lastspec], meta)

	for _,dataobj in pairs(Cork.sortedcorks) do if dataobj.Init then dataobj:Init() end end
	for _,dataobj in pairs(Cork.sortedcorks) do dataobj:Scan() end

	ae.RegisterEvent("Cork", "ZONE_CHANGED_NEW_AREA", Cork.Update)
	ae.RegisterEvent("Cork", "PLAYER_TALENT_UPDATE", function()
		if lastspec == GetSpecialization() then return end

		lastspec = GetSpecialization()
		for i,v in pairs(Cork.defaultspc) do if Cork.dbpc[i] == v then Cork.dbpc[i] = nil end end
		Cork.dbpc = setmetatable(CorkDBPC[lastspec], meta)

		if Cork.config.Update then Cork.config:Update() end
		for name,dataobj in pairs(Cork.corks) do if dataobj.Init then dataobj:Init() end end
		for name,dataobj in pairs(Cork.corks) do dataobj:Scan() end
	end)

	ae.UnregisterEvent("Cork", "PLAYER_LOGIN")
end)


ae.RegisterEvent("Cork", "PLAYER_LOGOUT", function()
	for i,v in pairs(defaults) do if Cork.db[i] == v then Cork.db[i] = nil end end
	for i,v in pairs(Cork.defaultspc) do if Cork.dbpc[i] == v then Cork.dbpc[i] = nil end end
end)

local onTaxi, petBattle
ae.RegisterEvent("Cork Core", "PLAYER_CONTROL_LOST", function()
	onTaxi = true
	Cork.Update()
end)

ae.RegisterEvent("Cork Core", "PLAYER_CONTROL_GAINED", function()
	onTaxi = nil
	Cork.Update()
end)

ae.RegisterEvent("Cork Core", "UNIT_ENTERED_VEHICLE", function()
	onTaxi = UnitHasVehicleUI('player')
	Cork.Update()
end)
ae.RegisterEvent("Cork Core", "UNIT_EXITED_VEHICLE", function()
	onTaxi = nil
	Cork.Update()
end)

ae.RegisterEvent("Cork Core", "PET_BATTLE_OPENING_START", function()
	petBattle = true
	Cork.Update()
end)
ae.RegisterEvent("Cork Core", "PET_BATTLE_OVER", function()
	petBattle = nil
	Cork.Update()
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

anchor:SetScript("OnClick", function(self) InterfaceOptionsFrame_OpenToCategory(Cork.config) end)


anchor:SetScript("OnDragStart", function(self)
	tooltip:Hide()
	self:StartMoving()
end)


anchor:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	Cork.db.point, Cork.db.x, Cork.db.y = "BOTTOMLEFT", self:GetLeft(), self:GetBottom()
	Cork.Update()
end)


-----------------------
--      Tooltip      --
-----------------------

tooltip = CreateFrame("GameTooltip", "Corkboard", UIParent, "GameTooltipTemplate")
tooltip:SetFrameStrata("MEDIUM")
CorkboardTextLeft1:SetFontObject(GameTooltipText)
CorkboardTextRight1:SetFontObject(GameTooltipText)


local function GetTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", frame, "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end


local function CorkSorter(a, b)
	return a and b and a.sortname < b.sortname
end


local function SetSort(dataobj)
	local downcase = dataobj.name:lower()
	dataobj.sortname = string.format("%02d %s", (dataobj.priority or 5), downcase)
end


local activecorks, usedcorks = {}, {}
local raidunits = {player = true}
for i=1,4 do raidunits["party"..i] = true end
for i=1,40 do raidunits["raid"..i] = true end
function Cork.Update(event, name, attr, value, dataobj)
	if attr == "name" then
		Cork.corks[value] = dataobj
	end

	if attr == "priority" or attr == "name" then
		SetSort(dataobj)
		table.sort(Cork.sortedcorks, CorkSorter)
	end

	if Cork.keyblist[attr] then return end

	tooltip:Hide()

	table.wipe(activecorks)
	table.wipe(usedcorks)

	local inbg = GetZonePVPInfo() == "combat" or select(2, IsInInstance()) == "pvp"

	for i,dataobj in ipairs(Cork.sortedcorks) do
		if dataobj.nobg and inbg then usedcorks[dataobj] = true end
	end

	for i,dataobj in ipairs(Cork.sortedcorks) do
		if not usedcorks[dataobj] and dataobj.player then
			table.insert(activecorks, dataobj)
			usedcorks[dataobj] = true
		end
	end

	for i,dataobj in ipairs(Cork.sortedcorks) do
		if not usedcorks[dataobj] then
			table.insert(activecorks, dataobj)
			usedcorks[dataobj] = true
	  end
	end


	tooltip:ClearLines()
	tooltip:SetOwner(anchor, "ANCHOR_NONE")
	tooltip:SetPoint(GetTipAnchor(anchor))

	if Cork.db.showbg or not inbg then
		local count = 0
		for i,dataobj in ipairs(activecorks) do
			if not (dataobj.nobg and inbg) then
				local inneed, numr, prefix = 0, GetNumGroupMembers(), IsInRaid() and "raid" or "party"
				for i=1,numr do if dataobj.RaidLine and dataobj[prefix..i] then inneed = inneed + 1 end end
				if dataobj.RaidLine and numr > 0 and dataobj["player"] then inneed = inneed + 1 end
				if inneed > 1 and count < 10 then -- Hard limit, show 10 lines at most
					if Cork.db.debug then tooltip:AddDoubleLine(string.format(dataobj.RaidLine, inneed), "raid") else tooltip:AddLine(string.format(dataobj.RaidLine, inneed)) end
					count = count + 1
				end
				for i,v in ldb:pairs(dataobj) do
					if v ~= false and not Cork.keyblist[i] and (inneed <= 1 or not raidunits[i]) and count < 10 then
						if Cork.db.debug then tooltip:AddDoubleLine(v, i) else tooltip:AddLine(v) end
						count = count + 1
					end
				end
			end
		end
	end

	if tooltip:NumLines() > 0 and not onTaxi and not petBattle then
		tooltip:Show()
	end
end


-------------------------
--      LDB stuff      --
-------------------------

local function NewDataobject(event, name, dataobj)
	if dataobj.type ~= "cork" then return end
	if not dataobj.name then dataobj.name = name:gsub("Cork ", "") end
	SetSort(dataobj)
	Cork.corks[name] = dataobj
	table.insert(Cork.sortedcorks, dataobj)
	table.sort(Cork.sortedcorks, CorkSorter)
	ldb.RegisterCallback("Corker", "LibDataBroker_AttributeChanged_"..name, Cork.Update)
end

ldb.RegisterCallback("Corker", "LibDataBroker_DataObjectCreated", NewDataobject)


function Cork:New(name)
	return ldb:NewDataObject("Cork "..name, {type = "cork", name = name})
end


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
	if onTaxi or InCombatLockdown() then return end
	for i,dataobj in ipairs(activecorks) do
		if dataobj.CorkIt and (not IsStealthed() or dataobj.CanCorkStealthed) and dataobj:CorkIt(self) then return end
	end
end)


secureframe:SetScript("PostClick", function()
	if InCombatLockdown() then return end
	secureframe:SetManyAttributes("type1", ATTRIBUTE_NOOP, "bag1", nil, "slot1", nil, "item1", nil, "spell", nil, "unit", nil, "macrotext1", nil)
end)


--------------------------------
--      Shared functions      --
--------------------------------

function Cork.IsSpellInRange(spell, unit)
	return IsSpellInRange(spell, unit) == 1
end

function Cork.SpellCastableOnUnit(spell, unit)
	return UnitExists(unit) and UnitCanAssist("player", unit) and UnitIsVisible(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) and Cork.IsSpellInRange(spell, unit)
end

function Cork.IconLine(icon, text, token)
	return "|T"..(icon or "")..":24:24:0:0:64:64:4:60:4:60|t ".. (token and ("|cff".. Cork.colors[token]) or "").. text
end

local last_thresh
function Cork.RaidThresh()
	if not last_thresh then
		local name, type, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance = GetInstanceInfo()
		last_thresh = maxPlayers < 10 and 8 or maxPlayers / 5
	end
	return last_thresh
end

local function FlushThresh()
	last_thresh = nil
	for name,dataobj in pairs(Cork.corks) do dataobj:Scan() end
end
ae.RegisterEvent("Cork Core", "PLAYER_DIFFICULTY_CHANGED", FlushThresh)
ae.RegisterEvent("Cork Core", "UPDATE_INSTANCE_INFO", FlushThresh)
-- ae.RegisterEvent("Cork Core", "GUILD_PARTY_STATE_UPDATED", FlushThresh)
-- ae.RegisterEvent("Cork Core", "PLAYER_GUILD_UPDATE", FlushThresh)
