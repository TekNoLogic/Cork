local name, Cork = ...
local ae = LibStub("AceEvent-3.0")

local name, _, icon = GetSpellInfo(181642)

local dataobj = Cork:GenerateSelfBuffer(name, icon)

function dataobj:Test()
    -- Need to have the toy
    local _, _, _, collected = C_ToyBox.GetToyInfo(122298)
    if not collected then return end

    -- Need to have a bodyguard assigned to a Barracks
    local found = false
    local buildings = C_Garrison.GetBuildings(LE_GARRISON_TYPE_6_0)
    for i = 1, #buildings do
       local buildingId = buildings[i].buildingID
       if buildingId >= 26 and buildingId <= 28 then -- Barracks
          if C_Garrison.GetFollowerInfoForBuilding(buildings[i].plotID) then found = true end
       end
    end
    if not found then return end

    return self:TestWithoutResting()
end

function dataobj:CorkIt(frame)
    if self.player then
        local macro = '/use ' .. name
        return frame:SetManyAttributes("type1", "macro", "macrotext1", macro)
    end
end

ae.RegisterEvent(dataobj, "ZONE_CHANGED", "Scan")
ae.RegisterEvent(dataobj, "GARRISON_UPDATE", "Scan")
