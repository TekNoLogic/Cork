
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

Cork = {}
local corks, blist = {}, {CorkIt = true, type = true}


-----------------------
--      Tooltip      --
-----------------------

local tooltip = CreateFrame("GameTooltip", "Corkboard", UIParent, "GameTooltipTemplate")
CorkboardTextLeft1:SetFontObject(GameTooltipText)
CorkboardTextRight1:SetFontObject(GameTooltipText)


-------------------------
--      LDB stuff      --
-------------------------

local function Update(event, name, attr, value, dataobj)
	if blist[attr] then return end

	tooltip:ClearLines()
	tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	tooltip:SetPoint("BOTTOMLEFT", WorldFrame, "BOTTOMLEFT", GetScreenWidth()/3, 300)

	for name,dataobj in pairs(corks) do
		for i,v in ldb:pairs(dataobj) do
			if not blist[i] then
				tooltip:AddLine(v)
			end
		end
	end

	if tooltip:NumLines() > 0 then tooltip:Show() end
end


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
