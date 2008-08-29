
local MAX_ACCOUNT_MACROS, MAX_CHARACTER_MACROS = IS_WRATH_BUILD and 36 or 18, 18

local function GetMacroID()
	for i=(MAX_ACCOUNT_MACROS+1),(MAX_ACCOUNT_MACROS+MAX_CHARACTER_MACROS) do if GetMacroInfo(i) == "Cork" then return i end end
end

function Cork.GenerateMacro()
	if InCombatLockdown() then return end

	local id = GetMacroID()
	if id then PickupMacro(id)
	elseif select(2, GetNumMacros()) < MAX_CHARACTER_MACROS then
		local body, ic, ooc
		local _, c = UnitClass("player")
		if c == "DEATHKNIGHT" then ooc = GetSpellInfo(3714)
		elseif c == "DRUID" then ic, ooc = GetSpellInfo(22812), GetSpellInfo(GetSpellInfo(21562)) or GetSpellInfo(1126)
		elseif c == "HUNTER" then ooc = GetSpellInfo(13165)
		elseif c == "MAGE" then ic, ooc = GetSpellInfo(168), GetSpellInfo(GetSpellInfo(23028)) or GetSpellInfo(1459)
		elseif c == "PALADIN" then ic, ooc = GetSpellInfo(21084), GetSpellInfo(GetSpellInfo(25782)) or GetSpellInfo(19740)
		elseif c == "PRIEST" then ic, ooc = GetSpellInfo(588), GetSpellInfo(GetSpellInfo(21849)) or GetSpellInfo(1243)
		elseif c == "SHAMAN" then ooc = GetSpellInfo(324)
		elseif c == "WARLOCK" then ooc = GetSpellInfo(687)
		elseif c == "WARRIOR" then ooc = GetSpellInfo(6673) end
		if ic and ooc then
			body = "#showtooltip [combat] "..ic.."; "..ooc.."\n/cast [combat] "..ic.."\n/stopmacro [combat]\n/click CorkFrame"
		elseif ooc then
			body = "#showtooltip "..ooc.."\n/click CorkFrame"
		else
			body = "/click CorkFrame"
		end
		local id = IS_WRATH_BUILD and CreateMacro("Cork", 1, body, true) or CreateMacro("Cork", 1, body, nil, true)
		PickupMacro(id)
	end
end
