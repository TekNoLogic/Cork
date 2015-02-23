Cork is a reminder addon, aimed primarily at buffs.  Cork was inspired long ago
by NeedyList, and has been Alpha quality for years.  Wrath introduces new buff
query APIs that let me finally make Cork as small as I'd prefer, so I'm finally pushing out a beta-quality version.

Cork provides, at it's heart, one-click buff casting.  Some non-buff reminders
are included as well:

* Reminders for self-only buffs, auras and shapeshifts
* Reminders for raid-group buffs (ones that cast on multiple targets)
* Reminders for warrior shouts only shown in combat
* Priest Fear Ward (shows whenever fear ward is not on cooldown, must be manually enabled when needed)
* Shaman Earth Shield (tracks the last group member cast on, so you must cast manually the first time)
* Warlock demons
* Warlock Soul Link
* Low durability warnings when resting (in town)
* Clam shucker
* Minimap tracking
* Keybinding (thanks cladhaire)
* Macro-generating button

## One-click? How?

Simple!  Make a macro: `/click CorkFrame`.  You might wish to add a
`/cast [combat] Some Spell` at the start as well.

You can also use the keybinding in the default k2eybind UI.

Be warned, Cork will only cast out of combat.  If you want to apply buffs in combat, you'll have to do it manually.
