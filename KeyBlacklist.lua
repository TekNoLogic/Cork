
local myname, ns = ...

local keys = {
	"configframe",
	"CorkIt",
	"icon",
	"iconline",
	"Init",
	"items",
	"lasttarget",
	"lowpriority",
	"name",
	"nobg",
	"RaidLine",
	"Scan",
	"spellname",
	"spells",
	"Test",
	"TestWithoutResting",
	"tiplink",
	"tiptext",
	"type",
	"UNIT_AURA",
}

ns.keyblist = {}
for i,key in pairs(keys) do ns.keyblist[key] = true end
