local myname, ns = ...
local IconLine = ns.IconLine

-- @todo danielp 2013-11-24: should I cache global functions from our loops
-- here, like GetContainerItemID and so forth?  I don't think so, but
-- ... worth considering for the future, maybe?

-- @todo danielp 2013-11-24: I don't think LDB is needed here?
local ldb, ae = LibStub:GetLibrary("LibDataBroker-1.1"), LibStub("AceEvent-3.0")

-- We use a generation counter to allow us to scan each item tooltip once, and
-- once only, when inventory updates no matter how many modules derive from
-- this, and how many are active.
--
-- This is necessary because we can't know what order they fire in, so we want
-- to make sure that the first, and only the first, scan triggers a cache
-- update -- and subsequent checks just reuse that data, trusting
-- our infrastructure.
--
-- This seems simpler and more efficient than doing the caching at the tooltip
-- text level, which we could use to make it faster to rescan items, but which
-- has the same invalidation challenge.
local cache_generation = 0

-- The patterns that we are scanning for in the tooltip.
--
-- These come from the individual modules, and are aggregated into this table
-- to allow us to scan in a single pass for all the modules.  The cache should
-- be invalidated if this ever changes.
local patterns = {}

-- Finally, the cache itself.  This maps the pattern to the ItemID for a
-- matching item, or contains nil if the item is absent.  No promises are made
-- about the ordering of items, other than that we try and be as efficient as
-- possible, so terminate early.
--
-- I can't identify a good reason to be fussy about ordering of what is
-- detected here, but if you can let me know. :)
--
-- maps [pattern string] => [item id number]
-- eg: itemids["foo"] == 1234 -- item 1234 matches pattern "foo"
local itemids = {}


-- Our tooltip frame itself, used for our private scanning purposes only.
-- This is never shown to anyone or any other fun things like that.
local tooltip = CreateFrame('GameTooltip', 'CorkScanTip', UIParent, 'GameTooltipTemplate')

-- The first 8 lines of text from that, from the global store.
-- These never change after creation of the frame, so we can cache them.
local text1 = CorkScanTipTextLeft1
local text2 = CorkScanTipTextLeft2
local text3 = CorkScanTipTextLeft3
local text4 = CorkScanTipTextLeft4
local text5 = CorkScanTipTextLeft5
local text6 = CorkScanTipTextLeft6
local text7 = CorkScanTipTextLeft7
local text8 = CorkScanTipTextLeft8

-- Actually scan the bags, and find anything that matches our tooltip
-- patterns; we update the cache and bump the generation automatically.
--
-- This should only be entered if we actually need a cache update, so we just
-- blindly trust our caller to get that right.  Many scans, handle it.
local function scan_bags()
   -- flush our cache, and a local alias for convenience.
   wipe(itemids)

   for bag = 0, NUM_BAG_SLOTS do
      -- check we have a bag in this slot
      if GetBagName(bag) then
         for slot = 1, GetContainerNumSlots(bag) do
            -- check we actually have something in this slot
            local itemid = GetContainerItemID(bag, slot)
            if itemid then
               -- put the item into the tooltip to get access to the text
               tooltip:SetOwner(UIParent, 'ANCHOR_NONE')
               tooltip:SetBagItem(bag, slot)

               -- we have access to the text, so for each pattern, maybe scan
               for _, pattern in pairs(patterns) do
                  -- Skip this if we already found a match for this pattern
                  -- earlier in the bags.  Avoids scanning for things more than
                  -- once, even if not perfectly.
                  if not itemids[pattern] then
                     -- @todo danielp 2013-11-24: this is O(n) calls to GetText
                     -- for n patterns; would it be faster to pre-cache these?
                     -- I think in most cases we are going to fetch all 8, and do
                     -- it at least two or three times, so maybe we should?
                     if text1:GetText() == pattern or
                        text2:GetText() == pattern or
                        text3:GetText() == pattern or
                        text4:GetText() == pattern or
                        text5:GetText() == pattern or
                        text6:GetText() == pattern or
                        text7:GetText() == pattern or
                        text8:GetText() == pattern
                     then
                        itemids[pattern] = itemid
                     end
                  end
               end
            end

            -- clear the tooltip again, ensuring it resets text, etc
            tooltip:Hide()
         end
      end

      -- if we found everything we can find, finish the process
      if #itemids == #patterns then
         break
      end
   end

   -- bump the cache generation
   cache_generation = cache_generation + 1
end

local function scan(self)
   if not ns.dbpc[self.name.."-enabled"] then
      self.player = nil
      return
   end

   -- Do we need to update our cache?  If we are invoked, we need to scan
   -- the bags again -- so we need the cache to be *newer* than our last
   -- scan, or we consider it invalid.
   --
   -- This might have a window where disabling and reenabling could cause
   -- you to miss an update, but that lasts at most one item
   -- manipulation, and should be pretty rare.
   if self.generation <= cache_generation then scan_bags() end
   self.generation = cache_generation

   -- Our cache is up to date, so ask it: do we have work?
   local itemid = itemids[self.match]
   if itemid then
      -- yup, better get the details.
      local num = GetItemCount(itemid)
      local itemname, _, _, _, _, _, _, _, _, texture = GetItemInfo(itemid)

      -- If the item was not in our cache, this could have nil values for the
      -- name and texture; given we have fetched it into the tooltip before
      -- now, I suspect that is never really going to be a problem for us.
      self.player = IconLine(texture, format("%s (%d)", itemname, num))
   else
      self.player = nil
   end

   return
end


local function corkit(self, frame)
   local itemid = itemids[self.match]
   if itemid then
      return frame:SetManyAttributes("type1", "item", "item1", "item:"..itemid)
   end
end


function ns.InitItemScanner(self)
   ns.defaultspc[self.name.."-enabled"] = true
   self.corktype = "item"
   self.CorkIt   = corkit
   self.Scan     = scan

   -- capture our pattern into the global set that we scan for
   tinsert(patterns, self.match)

   -- update our cache generation to zero, to start things off...
   self.generation = 0

   -- register for the update event that fires after a complete batch of
   -- changes, since we scan everything at once; reduces overscanning.
   ae.RegisterEvent(self, "BAG_UPDATE_DELAYED", "Scan")
end
