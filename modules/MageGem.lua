
local myname, Cork = ...
if Cork.MYCLASS ~= "MAGE" then return end


local myname, Cork = ...
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

local ITEM1 = 36799 -- regular mana gem
local ITEM2 = 81901 -- brilliant mana gem (glyphed)
local spellname, _, icon = GetSpellInfo(759)
local IconLine = Cork.IconLine(icon, spellname)

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Cork "..spellname, {type = "cork"})


function dataobj:Init()
	Cork.defaultspc[spellname.."-enabled"] = GetSpellInfo(spellname) ~= nil
end


function dataobj:Scan()
	if not Cork.dbpc[spellname.."-enabled"] then dataobj.player = nil; return end
	if GetItemCount(ITEM1) > 0 then dataobj.player = nil; return end
	if GetItemCount(ITEM2) > 0 then dataobj.player = nil; return end
	dataobj.player = IconLine
end
ae.RegisterEvent("Cork "..spellname, "BAG_UPDATE", dataobj.Scan)
ae.RegisterEvent("Cork "..spellname, "BAG_UPDATE_COOLDOWN", dataobj.Scan)


function dataobj:CorkIt(frame)
	if self.player then return frame:SetManyAttributes("type1", "spell", "spell", spellname) end
end
