
-- Dynamic mousewheel binding module, originally created by Adirelle <gperreal@free.fr>

local CORKNAME = "Mousewheel Bindings"

local dataobj =  LibStub('LibDataBroker-1.1'):NewDataObject("Cork "..CORKNAME, {type='cork'})
local frame
local keys = { 'MOUSEWHEELUP', 'MOUSEWHEELDOWN' }

------------------------------------------------------------------------------
-- Binding update
------------------------------------------------------------------------------

local function ClearBindings()
	if InCombatLockdown() then return end
	ClearOverrideBindings(frame)
end

local function UpdateBindings()
	if InCombatLockdown() then return end
	if Cork.dbpc[CORKNAME.."-enabled"] and Corkboard:IsVisible() and not IsStealthed() and not IsFlying() and not IsMounted() then
		for i,key in ipairs(keys) do
			SetOverrideBindingClick(frame, true, key, 'CorkFrame')
		end
	else
		ClearBindings()
	end
end

------------------------------------------------------------------------------
-- Addon setup
------------------------------------------------------------------------------

function dataobj:Init()
	Cork.defaultspc[CORKNAME..'-enabled'] = true

	frame = CreateFrame('Frame', 'CorkWheelFrame', Corkboard)
	frame:SetAllPoints(Corkboard)
	frame:SetScript('OnShow', UpdateBindings)
	frame:SetScript('OnHide', ClearBindings)
	frame:Show()

	local AE = LibStub('AceEvent-3.0')
	AE.RegisterEvent(self, 'PLAYER_AURAS_CHANGED', UpdateBindings)
	AE.RegisterEvent(self, 'PLAYER_REGEN_ENABLED', UpdateBindings)
	AE.RegisterEvent(self, 'PLAYER_REGEN_DISABLED', ClearBindings)
end

dataobj.Scan = UpdateBindings
