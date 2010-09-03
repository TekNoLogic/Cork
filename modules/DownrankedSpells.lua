
local myname, Cork = ...
if Cork.IHASCAT then return end  -- Don't load on cat!

local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

Cork.defaultspc["Downranked spells-enabled"] = true

local dataobj = ldb:NewDataObject("Cork Downranked spells", {type = "cork", tiptext = "Warn when your actionbars have spells that aren't the highest rank you know."})

local ranks = setmetatable({},{
	__index = function(t,i)
		local _, v = GetSpellInfo(i)
		if v then t[i] = v; return v end
	end
})

local function TestAction(id)
	local _, _, subtype, spellid = GetActionInfo(id)
	if subtype ~= "spell" then return end
	local spellname, rank, icon = GetSpellInfo(spellid)
	local _, bestrank = GetSpellInfo(spellname)
	x = ranks[spellname]
	return rank ~= bestrank, spellname, icon
end

local function ScanOne(event, id)
	if swapping then
		if id ~= 0 then return end
		swapping = false
		dataobj:Scan()
		return
	end

	if not Cork.dbpc["Downranked spells-enabled"] then
		dataobj.player = nil
		return
	end

	local bad, spell, icon = TestAction(id)
	if bad then dataobj.player = IconLine(icon, "You have downranked spells") end
end

function dataobj:Scan(...)
	dataobj.player = nil

	if not Cork.dbpc["Downranked spells-enabled"] or IsResting() then return end

	for i=1,120 do
		ScanOne(nil, i)
		if dataobj.player then return end
	end
end

ae.RegisterEvent("Cork Downranked spells", "ACTIVE_TALENT_GROUP_CHANGED", function() swapping = true end)
ae.RegisterEvent("Cork Downranked spells", "ACTIONBAR_SLOT_CHANGED", ScanOne)
ae.RegisterEvent("Cork Downranked spells", "SPELLS_CHANGED", function() table.wipe(ranks) end)
ae.RegisterEvent("Cork Downranked spells", "PLAYER_UPDATE_RESTING", dataobj.Scan)

function dataobj:CorkIt(frame)
	if dataobj.player then
		for i=1,120 do
			local bad, spell = TestAction(i)
			if bad then
				PickupSpell(spell)
				PlaceAction(i)
				repeat
					if CursorHasItem() or CursorHasSpell() then PickupSpell(1, BOOKTYPE_SPELL) end
				until not CursorHasItem() and not CursorHasSpell()
			end
		end
		self:Scan()
	end
end
