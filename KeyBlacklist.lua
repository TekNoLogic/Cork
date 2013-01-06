
local myname, ns = ...

local keys = {
	"configframe",
	"CorkIt",
	"icon",
	"Init",
	"items",
	"lasttarget",
	"lowpriority",
	"name",
	"nobg",
	"RaidLine",
	"Scan",
	"spells",
	"Test",
	"tiplink",
	"tiptext",
	"type",
}

ns.keyblist = {}
for i,key in pairs(keys) do ns.keyblist[key] = true end
