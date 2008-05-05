--[[
Name: SpecialEvents-Aura-2.0
Revision: $Rev: 28987 $
Author: Tekkub Stoutwrithe (tekkub@gmail.com)
Website: http://www.wowace.com/
Description: Special events for Auras, (de)buffs gained, lost etc.
Dependencies: AceLibrary, AceEvent-2.0
--]]

local vmajor, vminor = "SpecialEvents-Aura-2.0", "$Revision: 28987 $"

if not AceLibrary then error(vmajor .. " requires AceLibrary.") end
if not AceLibrary:HasInstance("AceEvent-2.0") then error(vmajor .. " requires AceEvent-2.0.") end
if not AceLibrary:IsNewVersion(vmajor, vminor) then return end

local lib = {}
AceLibrary("AceEvent-2.0"):embed(lib)

local RL

----------------------------
--     Initialization     --
----------------------------

local function registerevents(self)
	if self:IsEventRegistered("UNIT_AURA") then return end
	self:RegisterEvent("UNIT_AURA", "AuraScan")
	self:RegisterEvent("UNIT_AURASTATE", "AuraScan")
	self:RegisterBucketEvent("PLAYER_AURAS_CHANGED", 0.2)
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	-- check if RosterLib exists. We need to do that here and not earlier.
	if AceLibrary:HasInstance("Roster-2.1") then -- We're compatible with both.
		RL = AceLibrary("Roster-2.1")
	elseif AceLibrary:HasInstance("RosterLib-2.0") then
		RL = AceLibrary("RosterLib-2.0")
	end
	if RL then
		self:RegisterBucketEvent("RosterLib_UnitChanged", 0.2)
	else
		self:RegisterBucketEvent("PARTY_MEMBERS_CHANGED", 0.2)
		self:RegisterBucketEvent("RAID_ROSTER_UPDATE", 0.2)
	end
end


-- Activate a new instance of this library
function activate(self, oldLib, oldDeactivate)
	if oldLib then
		self.vars = oldLib.vars
		if type(self.vars) ~= "table" then self.vars = {} end
		if type(self.vars.buffs) ~= "table" then self.vars.buffs = {} end
		if type(self.vars.debuffs) ~= "table" then self.vars.debuffs = {} end
	else
		self.vars = { buffs = {}, debuffs = {} }
	end

	-- There's no need to re-scan all the auras if we have an oldLib and it has
	-- registered for events, which means it has already done one for us, and
	-- the data should be available in self.vars.
	if AceLibrary("AceEvent-2.0"):IsFullyInitialized() and (not oldLib or oldLib:IsEventRegistered("UNIT_AURA")) then
		self:PLAYER_LOGIN()
	end
	self:RegisterEvent("PLAYER_LOGIN")

	if oldLib and oldLib:IsEventRegistered("UNIT_AURA") then
		registerevents(self)
		oldLib:UnregisterAllEvents()
	end

	if oldDeactivate then oldDeactivate(oldLib) end
end

function lib:PLAYER_LOGIN()
	-- self:ScanAllAuras()
	registerevents(self)
end

--------------------------------
--      Tracking methods      --
--------------------------------

function lib:PLAYER_AURAS_CHANGED()
	self:AuraScan("player")
	if GetNumRaidMembers() > 0 then
		local u
		for i=1,GetNumRaidMembers() do
			if UnitIsUnit("raid"..i, "player") then u = "raid"..i end
		end
		self:AuraScan(u)
	end
end


function lib:PLAYER_TARGET_CHANGED()
	self:AuraScan("target")
	self:TriggerEvent("SpecialEvents_AuraTargetChanged")
end


function lib:PLAYER_FOCUS_CHANGED()
	self:AuraScan("focus")
	self:TriggerEvent("SpecialEvents_AuraFocusChanged")
end


function lib:RosterLib_UnitChanged(units)
	for unit in pairs(units) do
		if unit and UnitExists(unit) then
			self:AuraScan(unit)
		end
	end
	if GetNumRaidMembers() > 0 then
		self:TriggerEvent("SpecialEvents_AuraRaidRosterUpdate")
	else
		self:TriggerEvent("SpecialEvents_AuraPartyMembersChanged")
	end
end


function lib:PARTY_MEMBERS_CHANGED()
	if UnitExists("pet") then self:AuraScan("pet") end

	for i=1,4 do
		if UnitExists("party"..i) then self:AuraScan("party"..i) end
		if UnitExists("partypet"..i) then self:AuraScan("partypet"..i) end
	end
	self:TriggerEvent("SpecialEvents_AuraPartyMembersChanged")
end


function lib:RAID_ROSTER_UPDATE()
	for i=1,40 do
		if UnitExists("raid"..i) then self:AuraScan("raid"..i) end
		if UnitExists("raidpet"..i) then self:AuraScan("raidpet"..i) end
	end
	self:TriggerEvent("SpecialEvents_AuraRaidRosterUpdate")
end

function lib:ScanAllAuras()
	if UnitExists("player") then self:AuraScan("player") end
	if UnitExists("pet") then self:AuraScan("pet") end

	for i=1,4 do
		if UnitExists("party"..i) then self:AuraScan("party"..i) end
		if UnitExists("partypet"..i) then self:AuraScan("partypet"..i) end
	end

	for i=1,40 do
		if UnitExists("raid"..i) then self:AuraScan("raid"..i) end
		if UnitExists("raidpet"..i) then self:AuraScan("raidpet"..i) end
	end

	if UnitExists("target") then self:AuraScan("target") end
	if UnitExists("focus") then self:AuraScan("focus") end
--~~ 	if UnitExists("mouseover") then self:AuraScan("mouseover") end
end


-- whee, aura scanning is fun
do
	local maxbuffs, maxdebuffs = 32, 40

	local seenBuffs, seenDebuffs = {}, {}

	local removedBuffs = {
		name = {},
		rank = {},
		icon = {},
		count = {},
	}

	local removedDebuffs = {
		name = {},
		rank = {},
		icon = {},
		count = {},
		dispelType = {},
	}

	function lib:AuraScan(unit)
		local buffs, debuffs = self.vars.buffs[unit], self.vars.debuffs[unit]

		-- have we seen this unit before?
		if not buffs then
			buffs = {
				index = {},
				name = {},
				rank = {},
				icon = {},
				count = {},
			}

			self.vars.buffs[unit] = buffs

			debuffs = {
				index = {},
				name = {},
				rank = {},
				icon = {},
				count = {},
				dispelType = {},
			}

			self.vars.debuffs[unit] = debuffs
		end

		--
		-- Update buffs for unit
		--

		-- check for new buffs
		for i = 1, maxbuffs do
			local name, rank, icon, count
			
			-- Honest, there is no guaranteed correlation between the
			-- result of GetPlayerBuff and the index used by UnitBuff.
			-- GetPlayerBuff sucks, but we need it for backwards
			-- compatability.
			if unit == "player" then
				local pindex = GetPlayerBuff(i, "HELPFUL")
				name, rank = GetPlayerBuffName(pindex)
				icon = GetPlayerBuffTexture(pindex)
				count = GetPlayerBuffApplications(pindex)	
			else
				name, rank, icon, count = UnitBuff(unit, i)
			end

			if name then
				-- buffs are the same if their name, rank, and icon are the same
				local buffIndex = string.format("%s_%s_%s", name, rank, icon)

				-- handle multiple instances of the same buff (stacked HoTs)
				while seenBuffs[buffIndex] do
					buffIndex = buffIndex .. "_"
				end

				-- this is the only buff field that is allowed to change without triggering an event
				buffs.index[buffIndex] = i

				-- new buff?
				if not buffs.name[buffIndex] then
					buffs.name[buffIndex] = name
					buffs.rank[buffIndex] = rank
					buffs.icon[buffIndex] = icon
					buffs.count[buffIndex] = count

					seenBuffs[buffIndex] = "new"

				-- did the count change?
				elseif buffs.count[buffIndex] ~= count then
					buffs.count[buffIndex] = count

					seenBuffs[buffIndex] = "changed"

				-- no changes
				else
					seenBuffs[buffIndex] = true
				end
			end

		end

		-- remove old buffs
		for buffIndex in pairs(buffs.index) do
			if not seenBuffs[buffIndex] then
				-- copy to removed table
			removedBuffs.name[buffIndex] = buffs.name[buffIndex]
			removedBuffs.rank[buffIndex] = buffs.rank[buffIndex]
			removedBuffs.icon[buffIndex] = buffs.icon[buffIndex]
			removedBuffs.count[buffIndex] = buffs.count[buffIndex]

			-- remove buff from unit
			buffs.index[buffIndex] = nil
			buffs.name[buffIndex] = nil
			buffs.rank[buffIndex] = nil
			buffs.icon[buffIndex] = nil
			buffs.count[buffIndex] = nil
			end
		end

		--
		-- Update debuffs for unit
		--

		-- check for new debuffs
		for i = 1, maxdebuffs do
			local name, rank, icon, count, dispelType

			if unit == "player" then
				local pindex = GetPlayerBuff(i, "HARMFUL")
				name, rank = GetPlayerBuffName(pindex)
				icon = GetPlayerBuffTexture(pindex)
				count = GetPlayerBuffApplications(pindex)
				dispelType = GetPlayerBuffDispelType(pindex)
			else
				name, rank, icon, count, dispelType = UnitDebuff(unit, i) end

			if name then
				-- debuffs are the same if their name, rank, and icon are the same
				local debuffIndex = string.format("%s_%s_%s", name, rank, icon)

				-- handle multiple instances of the same debuff
				while seenDebuffs[debuffIndex] do
					debuffIndex = debuffIndex .. "_"
				end

				-- these are the only debuff fields that are allowed to change without triggering an event
				debuffs.index[debuffIndex] = i
				debuffs.dispelType[debuffIndex] = dispelType or ""

				-- new debuff?
				if not debuffs.name[debuffIndex] then
					debuffs.name[debuffIndex] = name
					debuffs.rank[debuffIndex] = rank
					debuffs.icon[debuffIndex] = icon
					debuffs.count[debuffIndex] = count

					seenDebuffs[debuffIndex] = "new"

				-- did the count change?
				elseif debuffs.count[debuffIndex] ~= count then
					debuffs.count[debuffIndex] = count

					seenDebuffs[debuffIndex] = "changed"

				-- no changes
				else
					seenDebuffs[debuffIndex] = true
				end
			end
		end

		-- remove old debuffs
		for debuffIndex in pairs(debuffs.index) do
			if not seenDebuffs[debuffIndex] then
				-- copy to removed table
				removedDebuffs.name[debuffIndex] = debuffs.name[debuffIndex]
				removedDebuffs.rank[debuffIndex] = debuffs.rank[debuffIndex]
				removedDebuffs.icon[debuffIndex] = debuffs.icon[debuffIndex]
				removedDebuffs.count[debuffIndex] = debuffs.count[debuffIndex]
				removedDebuffs.dispelType[debuffIndex] = debuffs.dispelType[debuffIndex]

				-- remove debuff from unit
				debuffs.index[debuffIndex] = nil
				debuffs.name[debuffIndex] = nil
				debuffs.rank[debuffIndex] = nil
				debuffs.icon[debuffIndex] = nil
				debuffs.count[debuffIndex] = nil
				debuffs.dispelType[debuffIndex] = nil
			end
		end

		--
		-- Done scanning, it's time to trigger events!
		--

		-- send events for lost buffs
		for buffIndex in pairs(removedBuffs.name) do
			local name = removedBuffs.name[buffIndex]
			local count = removedBuffs.count[buffIndex]
			local icon = removedBuffs.icon[buffIndex]
			local rank = removedBuffs.rank[buffIndex]

			-- unit, name, count, icon, rank
			self:TriggerEvent("SpecialEvents_UnitBuffLost", unit, name, count, icon, rank)

			if unit == "player" then
				-- name, count, icon, rank
				self:TriggerEvent("SpecialEvents_PlayerBuffLost", name, count, icon, rank)
			end

			removedBuffs.name[buffIndex] = nil
			removedBuffs.rank[buffIndex] = nil
			removedBuffs.icon[buffIndex] = nil
			removedBuffs.count[buffIndex] = nil
		end

		-- send events for lost debuffs
		for debuffIndex in pairs(removedDebuffs.name) do
			local name = removedDebuffs.name[debuffIndex]
			local count = removedDebuffs.count[debuffIndex]
			local dispelType = removedDebuffs.dispelType[debuffIndex]
			local icon = removedDebuffs.icon[debuffIndex]
			local rank = removedDebuffs.rank[debuffIndex]

			-- unit, name, count, dispelType, icon, rank
			self:TriggerEvent("SpecialEvents_UnitDebuffLost", unit, name, count, dispelType, icon, rank)

			if unit == "player" then
				-- name, count, dispelType, icon, rank
				self:TriggerEvent("SpecialEvents_PlayerDebuffLost", name, count, dispelType, icon, rank)
			end

			removedDebuffs.name[debuffIndex] = nil
			removedDebuffs.rank[debuffIndex] = nil
			removedDebuffs.icon[debuffIndex] = nil
			removedDebuffs.count[debuffIndex] = nil
			removedDebuffs.dispelType[debuffIndex] = nil
		end

		-- send events for new/changed buffs
		for buffIndex in pairs(buffs.index) do
			if seenBuffs[buffIndex] == "new" then
				local name = buffs.name[buffIndex]
				local index = buffs.index[buffIndex]
				local count = buffs.count[buffIndex]
				local icon = buffs.icon[buffIndex]
				local rank = buffs.rank[buffIndex]

				-- unit, name, index, count, icon, rank
				self:TriggerEvent("SpecialEvents_UnitBuffGained", unit, name, index, count, icon, rank)

				if unit == "player" then
					-- name, index, count, icon, rank
					self:TriggerEvent("SpecialEvents_PlayerBuffGained", name, index, count, icon, rank)
				end

			elseif seenBuffs[buffIndex] == "changed" then
				local name = buffs.name[buffIndex]
				local index = buffs.index[buffIndex]
				local count = buffs.count[buffIndex]
				local icon = buffs.icon[buffIndex]
				local rank = buffs.rank[buffIndex]

				-- unit, name, index, count, icon, rank
				self:TriggerEvent("SpecialEvents_UnitBuffCountChanged", unit, name, index, count, icon, rank)

				if unit == "player" then
					-- unit, name, index, count, icon, rank
					self:TriggerEvent("SpecialEvents_PlayerBuffCountChanged", name, index, count, icon, rank)
				end
			end
		end

		-- send events for new/changed debuffs
		for debuffIndex in pairs(debuffs.index) do
			if seenDebuffs[debuffIndex] == "new" then
				local name = debuffs.name[debuffIndex]
				local count = debuffs.count[debuffIndex]
				local dispelType = debuffs.dispelType[debuffIndex]
				local icon = debuffs.icon[debuffIndex]
				local rank = debuffs.rank[debuffIndex]
				local index = debuffs.index[debuffIndex]

				-- unit, name, count, dispelType, icon, rank, index
				self:TriggerEvent("SpecialEvents_UnitDebuffGained", unit, name, count, dispelType, icon, rank, index)

				if unit == "player" then
					-- name, count, dispelType, icon, rank, index
					self:TriggerEvent("SpecialEvents_PlayerDebuffGained", name, count, dispelType, icon, rank, index)
				end

			elseif seenDebuffs[debuffIndex] == "changed" then
				local name = debuffs.name[debuffIndex]
				local count = debuffs.count[debuffIndex]
				local dispelType = debuffs.dispelType[debuffIndex]
				local icon = debuffs.icon[debuffIndex]
				local rank = debuffs.rank[debuffIndex]
				local index = debuffs.index[debuffIndex]

				-- unit, name, count, dispelType, icon, rank, index
				self:TriggerEvent("SpecialEvents_UnitDebuffCountChanged", unit, name, count, dispelType, icon, rank, index)

				if unit == "player" then
					-- name, count, dispelType, icon, rank, index
					self:TriggerEvent("SpecialEvents_PlayerDebuffCountChanged", name, count, dispelType, icon, rank, index)
				end
			end
		end

		--
		-- cleanup
		--

		for k in pairs(seenBuffs) do
			seenBuffs[k] = nil
		end

		for k in pairs(seenDebuffs) do
			seenDebuffs[k] = nil
		end
	end
end


-----------------------------
--      Query Methods      --
-----------------------------

function lib:UnitHasBuff(unit, name, rank, icon)
	if not self.vars.buffs[unit] then return end

	local unitBuffs = self.vars.buffs[unit]

	if name and rank and icon then
		local buffIndex = string.format("%s_%s_%s", name, rank, icon)

		if unitBuffs.index[buffIndex] then
			-- index; count, icon, rank
			return unitBuffs.index[buffIndex], unitBuffs.count[buffIndex], unitBuffs.icon[buffIndex], unitBuffs.rank[buffIndex]
		else
			return
		end
	end

	for buffIndex in pairs(unitBuffs.index) do
		if (not name or name == unitBuffs.name[buffIndex]) and
			(not rank or rank == unitBuffs.rank[buffIndex]) and
			(not icon or icon == unitBuffs.icon[buffIndex]) then

			-- index; count, icon, rank
			return unitBuffs.index[buffIndex], unitBuffs.count[buffIndex], unitBuffs.icon[buffIndex], unitBuffs.rank[buffIndex]
		end
	end
end


function lib:UnitHasDebuff(unit, name, rank, icon)
	if not self.vars.debuffs[unit] then return end

	local unitDebuffs = self.vars.debuffs[unit]

	if name and rank and icon then
		local debuffIndex = string.format("%s_%s_%s", name, rank, icon)

		if unitDebuffs.index[debuffIndex] then
			-- index; count, icon, rank
			return unitDebuffs.index[debuffIndex], unitDebuffs.count[debuffIndex], unitDebuffs.icon[debuffIndex], unitDebuffs.rank[debuffIndex]
		else
			return
		end
	end

	for debuffIndex, debuffName in pairs(unitDebuffs.name) do
		if (not name or name == debuffName) and
			(not rank or rank == unitDebuffs.rank[debuffIndex]) and
			(not icon or icon == unitDebuffs.icon[debuffIndex]) then

			-- index; count, icon, rank
			return unitDebuffs.index[debuffIndex], unitDebuffs.count[debuffIndex], unitDebuffs.icon[debuffIndex], unitDebuffs.rank[debuffIndex]
		end
	end
end


function lib:UnitHasDebuffType(unit, dispelType)
	if not self.vars.debuffs[unit] then return end

	local unitDebuffs = self.vars.debuffs[unit]

	for debuffIndex, debuffDispelType in pairs(unitDebuffs.dispelType) do
		if debuffDispelType == dispelType then
			-- index, count, icon, rank
			return unitDebuffs.index[debuffIndex], unitDebuffs.count[debuffIndex], unitDebuffs.icon[debuffIndex], unitDebuffs.rank[debuffIndex]
		end
	end
end

local cache = setmetatable({},{__mode='k'})

local function donothing() end

local function iter(t)
	local unitBuffs, buffIndex = t.unitBuffs, t.buffIndex
	local index
	buffIndex, index = next(unitBuffs.index, buffIndex)
	if buffIndex then
		t.buffIndex = buffIndex
		-- name, index; count, icon, rank
		return unitBuffs.name[buffIndex], index, unitBuffs.count[buffIndex], unitBuffs.icon[buffIndex], unitBuffs.rank[buffIndex]
	else
		t.unitBuffs = nil
		t.buffIndex = nil
		cache[t] = true
	end
end
function lib:BuffIter(unit)
	local unitBuffs = self.vars.buffs[unit]
	local buffIndex
	
	if not unitBuffs then
		return donothing
	end
	
	local t = next(cache) or {}
	cache[t] = nil
	t.unitBuffs = unitBuffs
	
	return iter, t
end

local function iter(t)
	local unitDebuffs, debuffIndex = t.unitDebuffs, t.debuffIndex
	local index
	debuffIndex, index = next(unitDebuffs.index, debuffIndex)
	if debuffIndex then
		t.debuffIndex = debuffIndex
		-- name, count, , icon; rank, index
		return unitDebuffs.name[debuffIndex], unitDebuffs.count[debuffIndex], unitDebuffs.dispelType[debuffIndex], unitDebuffs.icon[debuffIndex], unitDebuffs.rank[debuffIndex], index
	else
		t.unitDebuffs = nil
		t.debuffIndex = nil
		cache[t] = true
	end
end
function lib:DebuffIter(unit)
	local unitDebuffs = self.vars.debuffs[unit]
	local debuffIndex, index
	
	if not unitDebuffs then
		return donothing
	end
	
	local t = next(cache) or {}
	cache[t] = nil
	t.unitDebuffs = unitDebuffs
	
	return iter, t
end

-------------------------------
--  Say hello to AceLibrary  --
-------------------------------
AceLibrary:Register(lib, vmajor, vminor, activate)
