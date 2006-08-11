
BINDING_HEADER_CORKFU = "FuBar - CorkFu"
BINDING_NAME_CORKFU_CORKFIRST = "Put a cork in it!"

------------------------------
--      Are you local?      --
------------------------------

local selern = SpecialEventsEmbed:GetInstance("Learn Spell 1")
local compost = CompostLib:GetInstance("compost-1")
local dewdrop = DewdropLib:GetInstance("1.0")
local tablet = TabletLib:GetInstance('1.0')
local tektech = TekTechEmbed:GetInstance("1")
local metro = Metrognome:GetInstance("1")
local babble = BabbleLib:GetInstance("Class 1.1")

local groupthresh = 3
local menus, menus3, dirty
local defaulticon, questionmark = "Interface\\Icons\\INV_Drink_11", "Interface\\Icons\\INV_Misc_QuestionMark"
local xpath = "Interface\\AddOns\\FuBar_CorkFu\\X.tga"
local sortbyname = function(a,b) return a and b and a.nicename < b.nicename end
local classes = {"DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR"}
local loc = {
	nofilter = "No Filter",
	disabled = "Disabled",
	headerunit = "Unit: ",
	headerparty = "Party: ",
	targetplayer = "Target Player",
	targetnpc = "Target NPC",
	unit = "Unit",
	class = "Class",
	party = "Party",
	everyone = "Everyone",
	rescanall = "Rescan All",
}
local raidunitnum, partyids = {}, {player = "Self", pet = "Pet"}
for i=1,40 do raidunitnum["raid"..i] = i end
for i=1,4 do
	partyids["party"..i] = "Party"
	partyids["party"..i.."pet"] = "Party Pet"
end


-------------------------------------
--      Namespace Declaration      --
-------------------------------------

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
	clickableTooltip = true,

	var = {},
})


---------------------------
--      Ace Methods      --
---------------------------

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
	metro:Register("CorkFu Refresh", self.OnTick, 0.5, self)
end


function FuBar_CorkFu:Enable()
	selern:RegisterEvent(self, "SPECIAL_LEARNED_SPELL")
	self:RegisterEvent("CORKFU_REGISTER_MODULE")
	self:RegisterEvent("CORKFU_UPDATE")
	metro:Start("CorkFu Refresh")
end


function FuBar_CorkFu:Disable()
	self:UnregisterAllEvents()
	selern:UnregisterAllEvents(self)
	metro:Stop("CorkFu Refresh")
end


------------------------------
--      Event Handlers      --
------------------------------

function FuBar_CorkFu:CORKFU_REGISTER_MODULE(module)
	assert(module, "No module passed")
	self.var.modules[module] = true
end


function FuBar_CorkFu:SPECIAL_LEARNED_SPELL(spell, rank)
	self:TriggerEvent("CORKFU_RESCAN", spell)
	self:Update()
end


function FuBar_CorkFu:CORKFU_UPDATE()
	dirty = true
end


function FuBar_CorkFu:OnTick()
	if not dirty then return end
	dirty = false
	self:Update()
end


-----------------------------
--      FuBar Methods      --
-----------------------------

function FuBar_CorkFu:OnClick()
	self:CorkFirst()
end


function FuBar_CorkFu:UpdateText()
	local module, unit, class = self:GetTopItem()
	if unit then _, class = UnitClass(unit) end

	local color = unit and (GetNumPartyMembers() > 0 and UnitInParty(unit) or GetNumRaidMembers() > 0 and UnitInRaid(unit)) and string.format("|cff%s", babble:GetHexColor(UnitClass(unit))) or "|cff00ff00"
	local name = unit and (color.. UnitName(unit))
	local icon = module and module.GetIcon and module:GetIcon(unit) or module and questionmark or defaulticon
	self:SetText(name or "CorkFu")
	self:SetIcon(icon)
end


function FuBar_CorkFu:UpdateTooltip()
	tablet:SetTitle("CorkFu")
	for i in pairs(self.var.modules) do
		if i:ItemValid() then
			local cat = tablet:AddCategory("columns", 2, "hideBlankLine", true)
			local groupneeds = {}
			if i.MultiValid and i:MultiValid() then self:GetGroupNeeds(i, groupneeds) end

			for group,num in pairs(groupneeds) do
				if num >= groupthresh then
					local icon = i and i.GetIcon and i:GetIcon("group"..group) or questionmark
					cat:AddLine("text", "Group "..group, "hasCheck", true, "checked", true, "checkIcon", icon, "text2", num.." units",
						"func", i.PutACorkInIt, "arg1", i, "arg2", "group"..group, "arg3", i)
				end
			end

			for unit,val in pairs(i.tagged) do
				if val == true and i:UnitValid(unit) and not self:UnitIsFiltered(i, unit) then
					local hidden
					local color = (UnitInParty(unit) or UnitInRaid(unit)) and string.format("|cff%s", babble:GetHexColor(UnitClass(unit))) or "|cff00ff00"
					local name = unit and (color.. UnitName(unit))
					local icon = i and i.GetIcon and i:GetIcon(unit) or questionmark
					local group
					if partyids[unit] then group = partyids[unit]
					elseif GetNumRaidMembers() > 0 and raidunitnum[unit] then
						_,_,group = GetRaidRosterInfo(raidunitnum[unit])
						hidden = groupneeds[group] and groupneeds[group] >= groupthresh
						group = "Group "..group
					end
					if not hidden then
						cat:AddLine("text", name, "hasCheck", true, "checked", true, "checkIcon", icon,
							"func", i.PutACorkInIt, "arg1", i, "arg2", unit, "arg3", i, "text2", group)
					end
				end
			end
		end
	end
end


function FuBar_CorkFu:GetGroupNeeds(module, t)
	if GetNumRaidMembers() == 0 then return end
	for unit,val in pairs(module.tagged) do
		if raidunitnum[unit] and val == true and module:UnitValid(unit) and not self:UnitIsFiltered(module, unit) then
			local _,_,group = GetRaidRosterInfo(raidunitnum[unit])
			t[group] = (t[group] or 0) + 1
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

function FuBar_CorkFu:Menu1(level, value, inTooltip, value1, value2, value3, value4)
	local sortlist = compost:Acquire()
	for i in pairs(self.var.modules) do table.insert(sortlist, i) end
	table.sort(sortlist, sortbyname)

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

	dewdrop:AddLine()
	dewdrop:AddLine("text", loc.rescanall, "func", self.RescanAll, "arg1", self)

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

		dewdrop:AddLine("text", loc.targetplayer, "value", "Target Player", "hasArrow", true)
		dewdrop:AddLine("text", loc.targetnpc, "value", "Target NPC", "hasArrow", true)
		dewdrop:AddLine("text", loc.unit, "value", "Unit", "hasArrow", true)
		dewdrop:AddLine("text", loc.class, "value", "Class", "hasArrow", true)
		dewdrop:AddLine("text", loc.party, "value", "Party", "hasArrow", true)
		dewdrop:AddLine("text", loc.everyone, "value", "Everyone", "hasArrow", true)
	else
		local everyone = tektech:TableGetVal(self.data, value.name, "Filters", "Everyone")
		local pc = tektech:TableGetVal(self.data, value.name, "Filters", "Target Player")
		local npc = tektech:TableGetVal(self.data, value.name, "Filters", "Target NPC")

		dewdrop:AddLine("text", loc.targetplayer, "func", self.ToggleFilter, "arg1", self, "arg2", value,
			"arg3", "Target Player", "checked", pc, pc == -1 and "checkIcon", pc == -1 and xpath)
		dewdrop:AddLine("text", loc.targetnpc, "func", self.ToggleFilter, "arg1", self, "arg2", value,
			"arg3", "Target NPC", "checked", npc, npc == -1 and "checkIcon", npc == -1 and xpath)
		dewdrop:AddLine("text", loc.unit, "value", "Unit", "hasArrow", true)
		dewdrop:AddLine("text", loc.class, "value", "Class", "hasArrow", true)
		dewdrop:AddLine("text", loc.party, "value", "Party", "hasArrow", true)
		dewdrop:AddLine("text", loc.everyone, "func", self.ToggleFilter, "arg1", self, "arg2", value,
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
			dewdrop:AddLine("text", loc.headerparty..i, "value", "Party: "..i, "hasArrow", true)
		else
			local p = tektech:TableGetVal(self.data, value1.name, "Filters", "Party: "..i)

			dewdrop:AddLine("text", loc.headerparty..i, "func", self.ToggleFilter, "arg1", self, "arg2", value1,
				"arg3", "Party: "..i, "checked", p, p == -1 and "checkIcon", p == -1 and xpath)
		end
	end
end


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

	table.sort(sortlist)

	for i,v in ipairs(sortlist) do
		if value1.k.spells then
			dewdrop:AddLine("text", loc.headerunit.. v, "value", "Unit: "..v, "hasArrow", true)
		else
			local p = tektech:TableGetVal(self.data, value1.name, "Filters", "Unit: "..v)

			dewdrop:AddLine("text", v, "func", self.ToggleFilter, "arg1", self, "arg2", value1,
				"arg3", "Unit: "..v, "checked", p, p == -1 and "checkIcon", p == -1 and xpath)
		end
	end

	compost:Reclaim(sortlist)
end


function FuBar_CorkFu:Menu3Class(level, value, inTooltip, value1, value2, value3, value4)
	for _,v in pairs(classes) do
		local class = babble:GetLocalized(v)
		local clstxt = string.format("|cff%s%s|r", babble:GetHexColor(class), class)
		if value1.k.spells then
			dewdrop:AddLine("text", clstxt, "value", "Class: "..v, "hasArrow", true)
		else
			local p = tektech:TableGetVal(self.data, value1.name, "Filters", "Class: "..v)

			dewdrop:AddLine("text", clstxt, "func", self.ToggleFilter, "arg1", self, "arg2", value1,
				"arg3", "Class: "..v, "checked", p, p == -1 and "checkIcon", p == -1 and xpath)
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
		dewdrop:AddLine("text", loc.nofilter, "func", self.SetFilter, "isRadio", true, "checked", not val, "arg1", self,
			"arg2", module, "arg3", unit)
	end
	dewdrop:AddLine("text", loc.disabled, "func", self.SetFilter, "isRadio", true, "checked", val == -1, "arg1", self,
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
	assert(unit == "player" or UnitExists(unit), module.name.." - ".. unit.." does not exist")

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


function FuBar_CorkFu:RescanAll()
	self:TriggerEvent("CORKFU_RESCAN", "All")
	self:Update()
end


--------------------------------
--      Load this bitch!      --
--------------------------------
FuBar_CorkFu:RegisterForLoad()
