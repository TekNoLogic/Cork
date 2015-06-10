
local myname, Cork = ...

local IconLine = Cork.IconLine
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

Cork.defaultspc["Archaeology solve-enabled"] = true

local dataobj2 = ldb:NewDataObject("Cork Archaeology Solving", {
    type = "cork",
    tiptext = "Warn when you can solve archeology artifacts"
})

local solveRace = nil

function dataobj2:Scan()
    if not Cork.dbpc["Archaeology solve-enabled"] then
        dataobj2.player = nil
        solveRace = nil
        return
    end

    local raceCount = GetNumArchaeologyRaces()

    for race = 1, raceCount do
        local name,_,_,have,need,max=GetArchaeologyRaceInfo(race)

        if(have>need) then
            SetSelectedArtifact(race)
            local _1,_2,_3,_4,_5,_6,_7 = GetSelectedArtifactInfo()
            dataobj2.player = IconLine(_4, name.."Artifact ("..have.."/"..need..")")
            solveRace = race
            return
        end
    end

    dataobj2.player = nil
    solveRace = nil
end


ae.RegisterEvent("Cork Archaeology Solving", "ARCHAEOLOGY_FIND_COMPLETE", dataobj2.Scan)
ae.RegisterEvent("Cork Archaeology Solving", "ARTIFACT_COMPLETE", dataobj2.Scan)
ae.RegisterEvent("Cork Archaeology Solving", "ARTIFACT_UPDATE", dataobj2.Scan)
ae.RegisterEvent("Cork Archaeology Solving", "BAG_UPDATE_DELAYED", dataobj2.Scan)
ae.RegisterEvent("Cork Archaeology Solving", "LOOT_CLOSED", dataobj2.Scan)

function dataobj2:CorkIt(frame)
    if dataobj2.player and solveRace then
        local macro = "/script SetSelectedArtifact("..solveRace..") SolveArtifact()"
        return frame:SetManyAttributes("type1", "macro", "macrotext1", macro)
    end
end
