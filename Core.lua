
local compost = CompostLib:GetInstance("compost-1")
local dewdrop = DewdropLib:GetInstance("1.0")
local tablet = TabletLib:GetInstance('1.0')
local tektech = TekTechEmbed:GetInstance("1")

local defaulticon = "Interface\\Icons\\INV_Drink_11"

FuBar_CorkFu = FuBarPlugin:GetInstance("1.2"):new({
	name          = "FuBar - CorkFu",
	version       = tonumber(string.sub("$Revision$", 12, -3)),
	releaseDate   = string.sub("$Date$", 8, 17),
	author        = "Tekkub Stoutwrithe",
	email         = "tekkub@gmail.com'",
	website       = "http://tekkub.wowinterface.com",
	aceCompatible = 103,
	category      = "interface",
	db            = AceDatabase:new("CorkFuDB"),
	cmd           = AceChatCmd:new({}, {}),

	hasIcon = defaulticon,

	var = {},
})


---------------------------
--      Ace Methods      --
---------------------------

local menus, menus3
function FuBar_CorkFu:Initialize()
	self.var.modules = {}
	menus = {self.Menu1, self.Menu2, self.Menu3, self.Menu4}
	menus3 = {
		Everyone          = self.Menu3Everyone,
		Unit              = self.Menu3Unit,
		Class             = self.Menu3Class,
		Party             = self.Menu3Party,
		["Target Player"] = self.Menu3Everyone,
		["Target NPC"]    = self.Menu3Everyone,
	}
end


function FuBar_CorkFu:Enable()
	self:RegisterEvent("CORKFU_REGISTER_MODULE")
	self:RegisterEvent("CORKFU_UPDATE", "Update")
end


function FuBar_CorkFu:Disable()
	self:UnregisterAllEvents()
end


------------------------------
--      Event Handlers      --
------------------------------

function FuBar_CorkFu:CORKFU_REGISTER_MODULE(module)
	assert(module, "No module passed")
	self.var.modules[module] = true
end


-----------------------------
--      FuBar Methods      --
-----------------------------

function FuBar_CorkFu:OnClick()
	self:CorkFirst()
end


local iconpath = "Interface\\Icons\\"
local classcolors = {PALADIN = "|cFFF48CBA", WARRIOR = "|cFFC69B6D", WARLOCK = "|cFF9382C9", PRIEST = "|cFFFFFFFF", DRUID = "|cFFFF7C0A", MAGE = "|cFF68CCEF", ROGUE = "|cFFFFF468", SHAMAN = "|cFFF48CBA", HUNTER = "|cFFAAD372"}
function FuBar_CorkFu:UpdateText()
	local module, unit, class = self:GetTopItem()
	if unit then _, class = UnitClass(unit) end
	local name = class and (((UnitInParty(unit) or UnitInRaid(unit)) and classcolors[class] or "|cff00ff00").. UnitName(unit))
	local icon = module and module.GetIcon and (iconpath.. module:GetIcon(unit)) or defaulticon
	self:SetText(name or "CorkFu")
	self:SetIcon(icon)
end


function FuBar_CorkFu:UpdateTooltip()
	tablet:SetTitle("CorkFu")
	for i in pairs(self.var.modules) do
		if i:ItemValid() then
			local cat = tablet:AddCategory("hideBlankLine", true)

			for unit,val in pairs(i.tagged) do
				if val == true and i:UnitValid(unit) and not self:UnitIsFiltered(i, unit) then
					local _, class = UnitClass(unit)
					local name = ((UnitInParty(unit) or UnitInRaid(unit)) and classcolors[class] or "|cff00ff00").. UnitName(unit)
					local icon = i and i.GetIcon and (iconpath.. i:GetIcon(unit)) or defaulticon
					cat:AddLine("text", name, "func", i.PutACorkInIt, "arg1", i, "arg2", unit, "arg3", i, "hasCheck", true, "checked", true, "checkIcon", icon)
				end
			end
		end
	end
end


function FuBar_CorkFu:MenuSettings(level, value, inTooltip, value1, value2, value3, value4)
	if inTooltip then return end

	local m = menus[level]
	if m then m(self, level, value, inTooltip, value1, value2, value3, value4) end
end


----------------------------
--      Menu Methods      --
----------------------------

local xpath = "Interface\\AddOns\\FuBar_CorkFu\\X.tga"
local sortfunc1 = function(a,b) return a and b and a.nicename < b.nicename end
function FuBar_CorkFu:Menu1(level, value, inTooltip, value1, value2, value3, value4)
	local sortlist = compost:Acquire()
	for i in pairs(self.var.modules) do table.insert(sortlist, i) end
	table.sort(sortlist, sortfunc1)

	for _,v in ipairs(sortlist) do
		if v.Menu then v:Menu(level, value, inTooltip, value1, value2, value3, value4)
		elseif v:ItemValid() then
			if v.k.selfonly and not v.k.spells then
				local val = tektech:TableGetVal(self.data, v.name, "Filters", "Everyone")
				local x
				if val == nil then x = -1 end
				dewdrop:AddLine("text", v.nicename or "No name???", "func", self.SetFilter, "arg1", self, "arg2", v,
					"arg3", "Everyone", "arg4", x, "checked", val, "checkIcon", xpath)
			else dewdrop:AddLine("text", v.nicename or "No name???", "hasArrow", true, "value", v) end
		end
	end

	compost:Reclaim(sortlist)
end


function FuBar_CorkFu:Menu2(level, value, inTooltip, value1, value2, value3, value4)
	assert(self.var.modules[value], "Invalid Module")
	if value.Menu then
		value:Menu(level, value, inTooltip, value1, value2, value3, value4)
		return
	end

	if value.k.spells and value.k.selfonly then
		self:MenuSpells(value, "Everyone")
	elseif value.k.spells then
		local everyone = tektech:TableGetVal(self.data, value.name, "Filters", "Everyone")
		local pc = tektech:TableGetVal(self.data, value.name, "Filters", "Target Player")
		local npc = tektech:TableGetVal(self.data, value.name, "Filters", "Target NPC")

		dewdrop:AddLine("text", "Target Player", "value", "Target Player", "hasArrow", true)
		dewdrop:AddLine("text", "Target NPC", "value", "Target NPC", "hasArrow", true)
		dewdrop:AddLine("text", "Unit", "value", "Unit", "hasArrow", true)
		dewdrop:AddLine("text", "Class", "value", "Class", "hasArrow", true)
		dewdrop:AddLine("text", "Party", "value", "Party", "hasArrow", true)
		dewdrop:AddLine("text", "Everyone", "value", "Everyone", "hasArrow", true)
	else
		local everyone = tektech:TableGetVal(self.data, value.name, "Filters", "Everyone")
		local pc = tektech:TableGetVal(self.data, value.name, "Filters", "Target Player")
		local npc = tektech:TableGetVal(self.data, value.name, "Filters", "Target NPC")

		dewdrop:AddLine("text", "Target Player", "func", self.ToggleFilter, "arg1", self, "arg2", value,
			"arg3", "Target Player", "checked", pc, pc == -1 and "checkIcon", pc == -1 and xpath)
		dewdrop:AddLine("text", "Target NPC", "func", self.ToggleFilter, "arg1", self, "arg2", value,
			"arg3", "Target NPC", "checked", npc, npc == -1 and "checkIcon", npc == -1 and xpath)
		dewdrop:AddLine("text", "Unit", "value", "Unit", "hasArrow", true)
		dewdrop:AddLine("text", "Class", "value", "Class", "hasArrow", true)
		dewdrop:AddLine("text", "Party", "value", "Party", "hasArrow", true)
		dewdrop:AddLine("text", "Everyone", "func", self.ToggleFilter, "arg1", self, "arg2", value,
			"arg3", "Everyone", "checked", everyone, everyone == -1 and "checkIcon", everyone == -1 and xpath)
	end
end


function FuBar_CorkFu:Menu3(level, value, inTooltip, value1, value2, value3, value4)
	if value1.Menu then
		value1:Menu(level, value, inTooltip, value1, value2, value3, value4)
		return
	elseif menus3[value] then menus3[value](self, level, value, inTooltip, value1, value2, value3, value4) end
end


function FuBar_CorkFu:Menu3Everyone(level, value, inTooltip, value1, value2, value3, value4)
	self:MenuSpells(value1, value)
end


function FuBar_CorkFu:Menu3Party(level, value, inTooltip, value1, value2, value3, value4)
	for i=1,8 do
		if value1.k.spells then
			dewdrop:AddLine("text", "Party: "..i, "value", "Party: "..i, "hasArrow", true)
		else
			local p = tektech:TableGetVal(self.data, value1.name, "Filters", "Party: "..i)

			dewdrop:AddLine("text", "Party "..i, "func", self.ToggleFilter, "arg1", self, "arg2", value1,
				"arg3", "Party: "..i, "checked", p, p == -1 and "checkIcon", p == -1 and xpath)
		end
	end
end


local sortfunc2 = function(a,b) return a<b end
function FuBar_CorkFu:Menu3Unit(level, value, inTooltip, value1, value2, value3, value4)
	local sortlist = compost:Acquire()
	local pmem, rmem = GetNumPartyMembers(), GetNumRaidMembers()
	if rmem > 0 then
		for i=1,rmem do
			table.insert(sortlist, UnitName("raid"..i))
			local pet = string.format("raid%dpet", i)
			if UnitExists(pet) then table.insert(sortlist, UnitName(pet)) end
		end
	elseif pmem > 0 then
		table.insert(sortlist, UnitName("player"))
		if UnitExists("pet") then table.insert(sortlist, UnitName("pet")) end
		for i=1,pmem do
			table.insert(sortlist, UnitName("party"..i))
			local pet = string.format("party%dpet", i)
			if UnitExists(pet) then table.insert(sortlist, UnitName(pet)) end
		end
	else
		table.insert(sortlist, UnitName("player"))
		if UnitExists("pet") then table.insert(sortlist, UnitName("pet")) end
	end

	table.sort(sortlist, sortfunc2)

	for i,v in ipairs(sortlist) do
		if value1.k.spells then
			dewdrop:AddLine("text", "Unit: "..v, "value", "Unit: "..v, "hasArrow", true)
		else
			local p = tektech:TableGetVal(self.data, value1.name, "Filters", "Unit: "..v)

			dewdrop:AddLine("text", v, "func", self.ToggleFilter, "arg1", self, "arg2", value1,
				"arg3", "Unit: "..v, "checked", p, p == -1 and "checkIcon", p == -1 and xpath)
		end
	end

	compost:Reclaim(sortlist)
end


local classes = {{"DRUID", "Druid"}, {"HUNTER", "Hunter"}, {"MAGE", "Mage"}, {"PALADIN", "Paladin"}, {"PRIEST", "Priest"}, {"ROGUE", "Rogue"}, {"SHAMAN", "Shaman"}, {"WARLOCK", "Warlock"}, {"WARRIOR", "Warrior"}}
function FuBar_CorkFu:Menu3Class(level, value, inTooltip, value1, value2, value3, value4)
	for _,v in pairs (classes) do
		if value1.k.spells then
			dewdrop:AddLine("text", classcolors[v[1]]..v[2], "value", "Class: "..v[1], "hasArrow", true)
		else
			local p = tektech:TableGetVal(self.data, value1.name, "Filters", "Class: "..v[1])

			dewdrop:AddLine("text", classcolors[v[1]]..v[2], "func", self.ToggleFilter, "arg1", self, "arg2", value1,
				"arg3", "Class: "..v[1], "checked", p, p == -1 and "checkIcon", p == -1 and xpath)
		end
	end
end


function FuBar_CorkFu:Menu4(level, value, inTooltip, value1, value2, value3, value4)
	self:MenuSpells(value2, value)
end


function FuBar_CorkFu:MenuSpells(module, unit)
	assert(module, "No module passed")
	assert(unit, "No unit passed")

	local def = module.k.defaultspell
	local val = tektech:TableGetVal(self.data, module.name, "Filters", unit) or (module.k.selfonly and def)
	local sortlist = compost:Acquire()
	for i in pairs(module.k.spells) do
		if tektech:SpellKnown(i) then table.insert(sortlist, i) end
	end
	table.sort(sortlist)

	if not module.k.selfonly then
		dewdrop:AddLine("text", "No Filter", "func", self.SetFilter, "isRadio", true, "checked", not val, "arg1", self,
			"arg2", module, "arg3", unit)
	end
	dewdrop:AddLine("text", "Disabled", "func", self.SetFilter, "isRadio", true, "checked", val == -1, "arg1", self,
		"arg2", module, "arg3", unit, "arg4", -1)
	for _,v in ipairs(sortlist) do
		local setval = module.k.selfonly and v ~= def and v or not module.k.selfonly and v
		dewdrop:AddLine("text", v, "func", self.SetFilter, "isRadio", true, "checked", val == v,
			"arg1", self, "arg2", module, "arg3", unit, setval and "arg4", setval)
	end

	compost:Reclaim(sortlist)
end

------------------------------
--      Filter Methods      --
------------------------------

function FuBar_CorkFu:ToggleFilter(module, unit)
	assert(module, "No module passed")
	assert(module.name, "Module does not have a name")
	assert(unit, "No unit passed")

	local v = tektech:TableGetVal(self.data, module.name, "Filters", unit)
	if v == 1 then tektech:TableSetVal(self.data, -1, module.name, "Filters", unit)
	elseif v == -1 then tektech:TableSetVal(self.data, nil, module.name, "Filters", unit)
	else tektech:TableSetVal(self.data, 1, module.name, "Filters", unit) end
	self:TriggerEvent("CORKFU_UPDATE")
end


function FuBar_CorkFu:SetFilter(module, unit, value)
	assert(module, "No module passed")
	assert(module.name, "Module does not have a name")
	assert(unit, "No unit passed")

	tektech:TableSetVal(self.data, value, module.name, "Filters", unit)
	self:TriggerEvent("CORKFU_UPDATE")
end


function FuBar_CorkFu:UnitIsFiltered(module, unit)
	assert(module, "No module passed")
	assert(module.name, "Module does not have a name")
	assert(unit, "No unit passed")
	assert(UnitExists(unit), "Unit does not exist")

	if module.k.selfonly then
		local v = tektech:TableGetVal(self.data, module.name, "Filters", "Everyone")
		return UnitName(unit) ~= UnitName("player") or v == -1
	end

	local istarget = unit == "target"
	local ispc = UnitIsPlayer(unit) and not UnitInParty(unit) and not UnitInRaid(unit)

	local pc = istarget and ispc and tektech:TableGetVal(self.data, module.name, "Filters", "Target Player")
	if pc then return pc == -1 end

	local npc = istarget and not ispc and tektech:TableGetVal(self.data, module.name, "Filters", "Target NPC")
	if npc then return npc == -1 end

	local byname = tektech:TableGetVal(self.data, module.name, "Filters", "Unit: "..UnitName(unit))
	if byname then return byname == -1 end

	local _,class = UnitClass(unit)
	local byclass = class and tektech:TableGetVal(self.data, module.name, "Filters", "Class: ".. class)
	if byclass then return byclass == -1 end

	local i, g, byparty
	if GetNumRaidMembers() > 0 then _, _, i = string.find(unit, "raid(%d+)") end
	if i then _, _, g = GetRaidRosterInfo(tonumber(i)) end
	if g then byparty = tektech:TableGetVal(self.data, module.name, "Filters", "Party: "..g) end
	if byparty then return byparty == -1 end

	local everyone = tektech:TableGetVal(self.data, module.name, "Filters", "Everyone")
	if everyone then return everyone == -1 end
end

------------------------------
--      Helper Methods      --
------------------------------

function FuBar_CorkFu:CorkFirst()
	local module, unit = self:GetTopItem()
	if not module then return end

	module:PutACorkInIt(unit)
end


function FuBar_CorkFu:GetTopItem()
	for i in pairs(self.var.modules) do
		if i:ItemValid() then
			for unit,val in pairs(i.tagged) do
				if val == true and i:UnitValid(unit) and not self:UnitIsFiltered(i, unit) then return i, unit end
			end
		end
	end
end


--------------------------------
--      Load this bitch!      --
--------------------------------
FuBar_CorkFu:RegisterForLoad()
