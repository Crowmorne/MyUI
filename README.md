# My UI

Personal World of Warcraft addon that sets up the UI entirely from code: install it, log in, play.
Nothing needs to be set up in game.


## What it does

- Builds an account-wide Edit Mode layout called "MyUI" from `Config.lua` on every login and `/reload`.
  Changes made to it by hand in Edit Mode don't last.
- Positions the action bars, status bars, cast bar, chat, menu buttons and unit frames.
- Replaces the player, target, target of target, focus and pet frames with custom [oUF](https://github.com/oUF-wow/oUF) frames.
- Moves the bag slots into the bag window and lifts the bag windows up from the bottom of the screen.


## Install

WoW only loads addons from its `Interface\AddOns` folder.
The repository likely lives elsewhere and is linked there.

On Windows, with a junction:

```powershell
New-Item -ItemType Junction -Path "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\MyUI" -Target "$HOME\development\MyUI"
```

On macOS, with a symbolic link:

```sh
ln -s ~/development/MyUI "/Applications/World of Warcraft/_forever_/Interface/AddOns/MyUI"
```


## Files

| File | Purpose |
| --- | --- |
| `Config.lua` | Values that get tuned, like positions and scales |
| `Core.lua` | Writes the Edit Mode layout and applies the config |
| `UnitFrames.lua` | Custom unit frames and their settings, like bar sizes |
| `Libs/oUF` | Bundled copy of oUF |


## Changing the layout

Edit `Config.lua`, then `/reload` in game.
Keys are the global names of Blizzard's frames, which `/fstack` shows in game.


## Commands

| Command | Purpose |
| --- | --- |
| `/myui` | Applies the config again without a reload |
| `/myui test` | Toggles dummy buffs and debuffs on the target frame |
