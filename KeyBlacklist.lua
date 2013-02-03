
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
	"slot",
	"spellname",
	"spells",
	"Test",
	"TestWithoutResting",
	"tiplink",
	"tiptext",
	"type",
	"UNIT_AURA",
	"UNIT_PET",
	"GROUP_ROSTER_UPDATE",
	"UNIT_INVENTORY_CHANGED",
	"oldtest",
}

ns.keyblist = {}
for i,key in pairs(keys) do ns.keyblist[key] = true end
