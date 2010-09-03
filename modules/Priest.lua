
local myname, Cork = ...
if Cork.MYCLASS ~= "PRIEST" then return end


if Cork.IHASCAT then
	-- Fort
	local spellname, _, icon = GetSpellInfo(21562)
	Cork:GenerateRaidBuffer(spellname, icon)


	-- Shadow Protection
	local spellname, _, icon = GetSpellInfo(27683)
	Cork:GenerateRaidBuffer(spellname, icon)
else
	-- Fort
	local multispell, spellname, _, icon = GetSpellInfo(21562), GetSpellInfo(1243)
	Cork:GenerateRaidBuffer(spellname, multispell, icon)


	-- Divine Spirit
	local multispell, spellname, _, icon = GetSpellInfo(27681), GetSpellInfo(14752)
	Cork:GenerateRaidBuffer(spellname, multispell, icon)


	-- Shadow Protection
	local multispell, spellname, _, icon = GetSpellInfo(27683), GetSpellInfo(976)
	Cork:GenerateRaidBuffer(spellname, multispell, icon)
end

-- Inner Fire
local spellname, _, icon = GetSpellInfo(588)
Cork:GenerateSelfBuffer(spellname, icon)


-- Shadowform
local spellname, _, icon = GetSpellInfo(15473)
Cork:GenerateSelfBuffer(spellname, icon)


-- Fear Ward
local spellname, _, icon = GetSpellInfo(6346)
Cork:GenerateLastBuffedBuffer(spellname, icon)


-- Vampiric Embrace
local spellname, _, icon = GetSpellInfo(15286)
Cork:GenerateSelfBuffer(spellname, icon)
