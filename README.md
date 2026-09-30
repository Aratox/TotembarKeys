# Totem Bar Keys

Key bindings for Blizzard's built-in totem bar on WoW Forever. No replacement
bar, no configuration window: the addon only adds entries to the game's
Keybindings menu.

## Bindings

Options → Keybindings → Totem Bar Keys

- **Slot 1–4: open totem selection** – opens the selection flyout of that slot.
  While it is open, press **1–9** to pick an entry and **ESC** to close it.
  Picking assigns the totem to the slot, exactly like clicking it.
- **Open call spell selection** – the same for the call spells.
- **Slot 1–4: drop totem** – drops the totem currently assigned to that slot.
- **Drop all totems (call spell)** and **Recall totems**.

The number keys are only redirected while a selection was opened by key. Your
normal bindings for 1–9 are untouched the rest of the time, and also when you
open the selection with the mouse.

## Install

Copy the folder into `Interface/AddOns` as `TotemBarKeys` and restart the game.

## Notes

- Shaman only. The addon does nothing on other classes.
- `/tbk` prints what the addon sees on the totem bar, useful for bug reports.
- Early release. If you switch the call spell page in combat, the drop keys
  follow the new page once combat ends.
