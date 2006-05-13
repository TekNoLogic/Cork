
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
	cmd           = AceChatCmd:new({}, {}),

	hasIcon = defaulticon,

	var = {},
})


function FuBar_CorkFu:Initialize()
	self.var.modules = {}
end


function FuBar_CorkFu:Enable()
	self:RegisterEvent("CORKFU_REGISTER_MODULE")
	self:RegisterEvent("CORKFU_UPDATE", "Update")
end


function FuBar_CorkFu:Disable()
end


function FuBar_CorkFu:OnClick()
	self:CorkFirst()
end


function FuBar_CorkFu:CORKFU_REGISTER_MODULE(module)
	assert(module, "No module passed")
	self.var.modules[module] = true
end


function FuBar_CorkFu:CorkFirst()
	local module, unit = self:GetTopItem()
	if not module then return end

	module:PutACorkInIt(unit)
end


function FuBar_CorkFu:GetTopItem()
	for i in pairs(self.var.modules) do
		if i:ItemValid() then
			for unit,val in pairs(i.tagged) do
				if val == true and i:UnitValid(unit) then return i, unit end
			end
		end
	end
end


local iconpath = "Interface\\Icons\\"
function FuBar_CorkFu:UpdateText()
	local module, unit = self:GetTopItem()
	self:SetText(unit and UnitName(unit) or "CorkFu")
	self:SetIcon(module and (iconpath.. module.k.icon) or defaulticon)
end


local classcolors = {PALADIN = "|cFFF48CBA", WARRIOR = "|cFFC69B6D", WARLOCK = "|cFF9382C9", PRIEST = "|cFFFFFFFF", DRUID = "|cFFFF7C0A", MAGE = "|cFF68CCEF", ROGUE = "|cFFFFF468", SHAMAN = "|cFFF48CBA", HUNTER = "|cFFAAD372"}
function FuBar_CorkFu:UpdateTooltip()
	tablet:SetTitle("CorkFu")
	for i in pairs(self.var.modules) do
		if i:ItemValid() then
			local cat = tablet:AddCategory("hideBlankLine", true)

			for unit,val in pairs(i.tagged) do
				if val == true and i:UnitValid(unit) then
					local _, class = UnitClass(unit)
					local name = ((UnitInParty(unit) or UnitInRaid(unit)) and classcolors[class] or "|cff00ff00").. UnitName(unit)
					cat:AddLine("text", name, "func", i.PutACorkInIt, "arg1", i, "arg2", unit, "arg3", i, "hasCheck", true, "checked", true, "checkIcon", iconpath.. i.k.icon)
				end
			end
		end
	end
end


function FuBar_CorkFu:MenuSettings()
--	local set = self.var.useset
--	local display = self.var.display
--	dewdrop:AddLine("text", "Metrognome", "isRadio", true, "checked", not set, "func", self.SetMode, "arg1", self, "arg2", nil)
--	dewdrop:AddLine("text", "OnUpdate Frames", "isRadio", true, "checked", set == 1, "func", self.SetMode, "arg1", self, "arg2", 1)
--	dewdrop:AddLine("text", "OnEvent Frames", "isRadio", true, "checked", set == 3, "func", self.SetMode, "arg1", self, "arg2", 3)
--	dewdrop:AddLine()
--	dewdrop:AddLine("text", "Time", "isRadio", true, "checked", not display, "func", self.SetDisplay, "arg1", self, "arg2", nil)
--	dewdrop:AddLine("text", "Memory", "isRadio", true, "checked", display == 1, "func", self.SetDisplay, "arg1", self, "arg2", 1)
end


FuBar_CorkFu:RegisterForLoad()
