
local myname, Cork = ...
if Cork.MYCLASS ~= "PALADIN" then return end
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

-- Righteous Fury
local spellname, _, icon = GetSpellInfo(25780)
Cork:GenerateSelfBuffer(spellname, icon)

-- Greater Blessings are any combination of 3 blessings across the whole raid.
local spellnames = {(GetSpellInfo(203538)), (GetSpellInfo(203528)), (GetSpellInfo(203539))}
local _, _, icon = GetSpellInfo(203538)
local rolespells = {TANK=1, DAMAGER=2, HEALER=3}
local dataobj = ldb:NewDataObject("Cork Greater Blessings", {
  type = "cork",
  corktype = "buff",
  tiplink = GetSpellLink(203538)
})

function dataobj:Init()
  Cork.defaultspc["Greater Blessings-enabled"] = GetSpellInfo(spellnames[1]) ~= nil
  print("Blessings init: "..(Cork.defaultspc["Greater Blessings-enabled"] and "enabled" or "disabled"))
end

local raidunits, partyunits, otherunits = {}, {}, { ["player"] = true }
for i=1,40 do raidunits["raid"..i] = i end
for i=1,4 do partyunits["party"..i] = i end
function dataobj:Test(unit)
  if not UnitExists(unit) or (unit ~= "player" and UnitIsUnit(unit, "player"))
    or (IsInRaid() and partyunits[unit])
    or (not raidunits[unit] and not partyunits[unit] and not otherunits[unit]) then return 0 end
  local count = 0
  for _, spellname in ipairs(spellnames) do
    if UnitAura(unit, spellname, nil, "PLAYER") then
      count = count + 1
    end
  end
  return count
end
function dataobj:Scan(enteringcombat)
  if not Cork.dbpc["Greater Blessings-enabled"] or (IsResting() and not Cork.db.debug) or (enteringcombat or InCombatLockdown()) then
    self.player = nil
    return
  end
  local count = 0
  -- We can't scan the same unit twice or we'll get inaccurate results
  if IsInRaid() then
    for k, _ in pairs(raidunits) do
      count = count + self:Test(k)
      if count >= 3 then break end
    end
  else
    count = self:Test("player")
    if IsInGroup() then
      for k, _ in pairs(partyunits) do
        count = count + self:Test(k)
        if count >= 3 then break end
      end
    end
  end
  if count < 3 then
    self.player = Cork.IconLine(icon, string.format("Greater Blessings (%d)", 3 - count))
  else
    self.player = nil
  end
end
function dataobj:CorkIt(frame)
  if self.player and Cork.SpellCastableOnUnit(spellnames[1], "player") then
    -- figure out which spell in the list we don't have
    -- prioritize the first spell based on our role
    local role = GetSpecializationRole(GetSpecialization())
    local rolespell = rolespells[role]
    if role and not UnitAura("player", spellnames[rolespell], nil, "PLAYER") then -- should this be player-only?
      return frame:SetManyAttributes("type1", "spell", "spell", spellnames[rolespell], "unit", "player")
    end
    -- otherwise just do the spells in order
    for _, spellname in ipairs(spellnames) do
      if not UnitAura("player", spellname, nil, "PLAYER") then -- should this be player-only?
        return frame:SetManyAttributes("type1", "spell", "spell", spellname, "unit", "player")
      end
    end
  end
end
local function isScanUnit(unit)
	return not not (raidunits[unit] or partyunits[unit] or otherunits[unit])
end
function dataobj:TestUnit(event, unit)
  if isScanUnit(unit) then self:Scan() end
end
ae.RegisterEvent(dataobj, "UNIT_AURA", "TestUnit")
ae.RegisterEvent(dataobj, "GROUP_ROSTER_UPDATE", "TestUnit")
ae.RegisterEvent(dataobj, "PLAYER_UPDATE_RESTING", function () dataobj:Scan() end)
ae.RegisterEvent(dataobj, "PLAYER_REGEN_DISABLED", function () dataobj:Scan(true) end)
ae.RegisterEvent(dataobj, "PLAYER_REGEN_ENABLED", function () dataobj:Scan() end)

-- Beacon of Light
local spellname, _, icon = GetSpellInfo(53563)
local dataobj = Cork:GenerateLastBuffedBuffer(spellname, icon)
dataobj.partyonly = true
dataobj.ignoreplayer = true
