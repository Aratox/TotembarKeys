# Totem Bar Keys

Key bindings for **Blizzard's own totem bar** on WoW Forever.

This addon does **not** add a totem bar of its own. It uses the default totem
bar that comes with the game, exactly as it is: same look, same position, same
selection flyout. All it does is add eight entries to the game's Keybindings
menu, so you can work that bar from the keyboard. There is no configuration
window.

## Bindings

Options → Keybindings → Totem Bar Keys

- **Slot 1–4: open totem selection** – opens the selection flyout of that slot
  on Blizzard's totem bar. While it is open, press **1–9** to pick an entry and
  **ESC** to close it. Picking assigns the totem to the slot, exactly like
  clicking it.
- **Slot 1–4: drop totem** – drops the totem currently assigned to that slot.

The number keys are only redirected while a selection was opened by key. Your
normal bindings for 1–9 are untouched the rest of the time, and also when you
open the selection with the mouse. While the selection is open, each entry
shows the number that picks it.

Selecting and dropping both work in combat. A totem you pick in combat is used
right away: the slot's drop key drops the newly selected totem.

## Install

Copy the folder into `Interface/AddOns` as `TotemBarKeys` and restart the game.

## Notes

- Shaman only. The addon does nothing on other classes.
- Needs Blizzard's totem bar to be shown. If you use an addon that hides it and
  brings its own totem bar instead, this addon has nothing to work with.
- If you switch the call spell page in combat, the drop keys follow the new
  page once combat ends.
- `/tbk` prints what the addon sees on the totem bar, which helps with bug
  reports.
