
local myname, Cork = ...
local SpellCastableOnUnit = Cork.SpellCastableOnUnit
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local IconLine = Cork.IconLine("Interface\\Icons\\Ability_Marksmanship", "Unspent talent points")
Cork.defaultspc["Talents-enabled"] = true

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject(
  "Cork Talents",
  {type = "cork", tiptext = "Warn when you have unspent talent points."}
)

function dataobj:Init()
  if Cork.dbpc["Talents-enabled"] then TalentMicroButtonAlert:Hide() end
end

local function talentlesshack()
 	return GetNumUnspentTalents() > 0
end
local function Test()
  return Cork.dbpc["Talents-enabled"] and talentlesshack() and IconLine
end

function dataobj:Scan() dataobj.player = Test() end

ae.RegisterEvent("Cork Talents", "CHARACTER_POINTS_CHANGED", dataobj.Scan)
ae.RegisterEvent("Cork Talents", "PLAYER_TALENT_UPDATE", dataobj.Scan)
ae.RegisterEvent("Cork Talents", "ACTIVE_TALENT_GROUP_CHANGED", dataobj.Scan)


TalentMicroButtonAlert:SetScript("OnShow", function(self)
  if Cork.dbpc["Talents-enabled"] then self:Hide() end
end)
