
local myname, ns = ...
local level = UnitLevel("player")
local ae = LibStub("AceEvent-3.0")


-- Items only available when you have a garrison
if level < 90 then return end

local cacheSizeQuestId = {
   { questId=37485, size=1000 },
}

local name = "Garrison cache"


local dataobj    = ns:New(name)
dataobj.tiptext  = "Notify you when you are in your garrison and the resource cache is unopened"
dataobj.priority = 20
ns.defaultspc[name.."-enabled"] = true


local function SecondsSinceLastOpened()
    local lasttime = ns.dbpc[name.."-lastopen"] or 0
    return time() - lasttime
end


local function Test()
    if not C_Garrison.IsOnGarrisonMap() then return end
    return SecondsSinceLastOpened() > (60*10*5)
end


function dataobj:Scan()
    if ns.dbpc[self.name.."-enabled"] and Test() then
        local myCacheSize = 500
        for _, cacheSize in pairs(cacheSizeQuestId) do
            if(_G.IsQuestFlaggedCompleted(cacheSize.questId)) then
                myCacheSize = cacheSize.size;
            end
        end
        local size = math.min(myCacheSize, math.floor(SecondsSinceLastOpened() / 60 / 10))
        if not ns.dbpc[name.."-lastopen"] then
            self.player = ns.IconLine("Interface\\ICONS\\inv_garrison_resource", name)
            return
        end

        local title = string.format("%s (%d/%d)", name, size, myCacheSize)
        self.player = ns.IconLine("Interface\\ICONS\\inv_garrison_resource", title)
    else
        self.player = nil
    end
end


ae.RegisterEvent(dataobj, "ZONE_CHANGED", "Scan")
ae.RegisterEvent("Cork "..name, "SHOW_LOOT_TOAST", function(event, ...)
    local _, _, _, _, _, _, lootSource = ...
    if lootSource == 10 then
        ns.dbpc[name.."-lastopen"] = time()
    end

    dataobj:Scan()
end)
