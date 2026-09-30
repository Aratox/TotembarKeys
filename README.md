# Totem Bar Keys

Key bindings for Blizzard's built-in totem bar on WoW Forever. No replacement
bar and no configuration window: the addon only adds eight entries to the
game's Keybindings menu.

## Bindings

Options → Keybindings → Totem Bar Keys

- **Slot 1–4: open totem selection** – opens the selection flyout of that slot.
  While it is open, press **1–9** to pick an entry and **ESC** to close it.
  Picking assigns the totem to the slot, exactly like clicking it.
- **Slot 1–4: drop totem** – drops the totem currently assigned to that slot.

The number keys are only redirected while a selection was opened by key. Your
normal bindings for 1–9 are untouched the rest of the time, and also when you
open the selection with the mouse. While the selection is open, each entry
shows the number that picks it.

Selecting and dropping both work in combat.

## Install

Copy the folder into `Interface/AddOns` as `TotemBarKeys` and restart the game.

## Notes

- Shaman only. The addon does nothing on other classes.
- Works with the default totem bar. It is not needed if you use an addon that
  replaces the totem bar with its own.
- If you switch the call spell page in combat, the drop keys follow the new
  page once combat ends.
- `/tbk` prints what the addon sees on the totem bar, which helps with bug
  reports.
