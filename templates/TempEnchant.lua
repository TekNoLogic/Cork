
local myname, Cork = ...
local UnitAura = Cork.UnitAura or UnitAura
local ldb = LibStub:GetLibrary("LibDataBroker-1.1")

local MAINHAND, OFFHAND, RANGED = GetInventorySlotInfo("MainHandSlot"), GetInventorySlotInfo("SecondaryHandSlot"), GetInventorySlotInfo("RangedSlot")
local offhands = {INVTYPE_WEAPON = true, INVTYPE_WEAPONOFFHAND = true}
local IconLine = Cork.IconLine

-- Creates a module for applying temp enchants (poisons, etc) to weapons
--
-- weaponslot - The name of the slot this module is for, best use the globalstrings
--              INVTYPE_WEAPONMAINHAND, INVTYPE_WEAPONOFFHAND or INVTYPE_THROWN
-- minlevel - Lowest level to activate this module for
-- spellids - List of spellIDs to use for name and icon lookups
-- itemmap - A table containing a table of itemIDs for each spellid
function Cork:GenerateTempEnchant(slotname, minlevel, spellids, itemmap)
	local weaponindex
	if     slotname == INVTYPE_WEAPONMAINHAND then weaponindex, weaponslot = 1, 16
	elseif slotname == INVTYPE_WEAPONOFFHAND  then weaponindex, weaponslot = 2, 17
	elseif slotname == INVTYPE_THROWN         then weaponindex, weaponslot = 3, 18
	else return end

	local f, elapsed = CreateFrame("Frame"), 0
	local modulename = "Temp Enchant "..slotname

	local buffnames, icons = {}, {}
	for _,id in pairs(spellids) do
		local spellname, _, icon = GetSpellInfo(id)
		buffnames[id], icons[spellname] = spellname, icon
	end

	Cork.defaultspc[modulename.."-enabled"] = UnitLevel("player") >= minlevel
	Cork.defaultspc[modulename.."-spell"] = buffnames[spellids[1]]

	local dataobj = ldb:NewDataObject("Cork "..modulename, {type = "cork"})

	function dataobj:Scan() if Cork.dbpc[modulename.."-enabled"] then f:Show() else f:Hide(); dataobj.custom = nil end end

	function dataobj:CorkIt(frame)
		if not dataobj.custom then return end
		for _,id in ipairs(itemmap[Cork.dbpc[modulename.."-spell"]]) do
			if (GetItemCount(id) or 0) > 0 then return frame:SetManyAttributes("type1", "macro", "macrotext1", "/use item:"..id.."\n/use "..weaponslot) end
		end
	end

	f:SetScript("OnUpdate", function(self, elap)
		elapsed = elapsed + elap
		if elapsed < 0.5 then return end
		elapsed = 0

		-- Return out if resting (with debug off) or if we have an active spell
		if (IsResting() and not Cork.db.debug) or select(weaponindex*3-2, GetWeaponEnchantInfo()) then dataobj.custom = nil return end

		-- Check that we have the right weapon type equipped
		if slotname == INVTYPE_WEAPONMAINHAND then
			if not GetInventoryItemLink("player", MAINHAND) then dataobj.custom = nil return end
		elseif slotname == INVTYPE_WEAPONOFFHAND then
			local offlink = GetInventoryItemLink("player", OFFHAND)
			if not offlink or not offhands[select(9, GetItemInfo(offlink))] then dataobj.custom = nil return end
		elseif slotname == INVTYPE_THROWN then
			local rangedlink = GetInventoryItemLink("player", RANGED)
			if not rangedlink or select(9, GetItemInfo(rangedlink)) ~= "INVTYPE_THROWN" then dataobj.custom = nil return end
		end


		local icon = icons[Cork.dbpc[modulename.."-spell"]]
		dataobj.custom = IconLine(icon, slotname)
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
		local buffbuttons = {}

		local function OnClick(self)
			Cork.dbpc[modulename.."-spell"] = self.buff
			for buff,butt in pairs(buffbuttons) do butt:SetChecked(butt == self) end
			dataobj:Scan()
		end

		local function OnEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.buff)
		end
		local function OnLeave() GameTooltip:Hide() end

		local function MakeButt(buff)
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

			return butt
		end

		local lasticon
		for _,id in ipairs(spellids) do
			local buff = buffnames[id]
			local butt = MakeButt(buff)
			if lasticon then lasticon:SetPoint("RIGHT", butt, "LEFT", -ROWGAP, 0) end
			buffbuttons[buff], lasticon = butt, butt
		end
		lasticon:SetPoint("RIGHT", 0, 0)

		local function Update(self)
			for buff,butt in pairs(buffbuttons) do
				butt:SetChecked(Cork.dbpc[modulename.."-spell"] == buff)
				butt:Enable()
				butt.icon:SetVertexColor(1.0, 1.0, 1.0)
			end
		end

		frame:SetScript("OnShow", Update)
		Update(frame)
	end)
end
