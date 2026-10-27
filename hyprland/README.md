# YunYun Syndrome — Hyprland

A Hyprland adaptation of the **YunYun Syndrome!? Rhythm Psychosis** KDE Plasma theme by
**Miyuki Denpa**. The colors, frames and window decoration all come from the original
KDE theme in this repository.

It installs as **its own login session**, "Hyprland (YunYun Syndrome)", next to whatever
you already use. Your regular `~/.config/hypr`, Noctalia/Waybar/etc. setup, kitty config and
shell rc files are never read or modified, and `uninstall.sh` removes everything it added.

## What you get

| KDE Plasma piece | Hyprland version |
| --- | --- |
| Plasma panel (launcher, task list, clock) | Quickshell panel drawn with the Plasma SVG frames, two-row task list, tray, big clock |
| Audio visualizer in the panel | Dot-matrix visualizer fed by `cava` |
| Kickoff start menu | Launcher with favorites, categories, search and power/session buttons |
| KRunner search | Search mode of the launcher |
| Digital clock calendar | Calendar popup with Days / Months / Years |
| Desktop decorations | Checkered strips, purple/pink corner bars and the three side icons (wallpaper picker, fullscreen, Downloads) |
| Aurorae window decoration | `hyprbars` titlebars + square magenta/blue borders |
| Color scheme | GTK theme (on adw-gtk3), qt6ct palette, kdeglobals |
| Lock screen | Quickshell lock screen with the same frames |
| kitty + fastfetch + prompt in the screenshots | kitty colors sampled from the screenshots, fastfetch layout, starship prompt |

## Install

Arch Linux (or an Arch-based distro) only.

```sh
git clone <this repo>
cd YunYun-Syndrome-KDE-Plasma-Theme/hyprland
./install.sh            # or ./install.sh --dry-run to see what it would do
```

The installer asks for:

1. **A wallpaper** (optional): any png/jpg/webp, or an animated gif. You can change it later
   with <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>W</kbd> or the picture icon on the desktop.
2. **A fastfetch logo** (optional): the image shown next to fastfetch in kitty.
3. **App theming**:
   - *Only in the YunYun session* (default). GTK and Qt apps are themed through environment
     variables and a separate GSettings database used only by this session. libadwaita (GNOME)
     apps and some KDE apps stay partly unthemed, because they only read user-wide files.
   - *Everywhere*: exact look in all apps, but it also changes your other sessions. Your
     current `kdeglobals`, `qt6ct.conf`, `gtk-4.0/gtk.css` and GSettings values are backed up.

Then it installs the missing packages with pacman, downloads the Candy icons, adds the login
session (sudo) and builds the `hyprbars` plugin with hyprpm (sudo). Log out and pick
**Hyprland (YunYun Syndrome)** in your login screen.

### What it changes

| Where | What |
| --- | --- |
| `~/.config/yunyun-syndrome/` | The whole theme: Hyprland, Quickshell, kitty, fastfetch, starship config |
| `~/.local/share/yunyun-syndrome/` | Install manifest, backups, `uninstall.sh` |
| `~/.local/share/icons/candy-icons` | Candy icons (if you don't have them already) |
| `~/.local/share/themes/YunYunSyndrome` | GTK theme |
| `~/.config/dconf/yunyun-syndrome` | The session's own GSettings database (per-session theming) |
| `/usr/local/bin/yunyun-syndrome-session`, `/usr/share/wayland-sessions/yunyun-syndrome.desktop` | The login session |
| `/var/cache/hyprpm/$USER` | hyprpm's header cache and the hyprbars build |
| pacman | Only packages you didn't have; the list is shown before installing |
| "Everywhere" theming only | `~/.config/kdeglobals`, `~/.config/qt6ct/`, `~/.config/gtk-4.0/gtk.css`, GSettings `org.gnome.desktop.interface` |

The `hyprbars` plugin is built but never `hyprpm enable`d, so other Hyprland configs that run
`hyprpm reload` don't get titlebars.

## Uninstall

```sh
~/.local/share/yunyun-syndrome/uninstall.sh     # or with --dry-run
```

It reads the manifest written during install and:

- restores every file and GSettings value the installer changed,
- removes every file, folder and login-session entry it created, and the hyprpm repository it added,
- offers to remove the packages it installed (with dependencies nothing else needs).

A file that was changed by something else after the install (for example, you edited
`kdeglobals`) is left alone and listed at the end. Your original stays in the backups folder.

## Keybinds

| Keys | Action |
| --- | --- |
| <kbd>Super</kbd> (tap) or <kbd>Super</kbd>+<kbd>Space</kbd> | Launcher |
| <kbd>Super</kbd>+<kbd>Return</kbd> | kitty |
| <kbd>Super</kbd>+<kbd>E</kbd> | File manager |
| <kbd>Super</kbd>+<kbd>Q</kbd> | Close window |
| <kbd>Super</kbd>+<kbd>F</kbd> / <kbd>M</kbd> | Fullscreen / maximize |
| <kbd>Super</kbd>+<kbd>V</kbd> | Toggle floating |
| <kbd>Super</kbd>+<kbd>N</kbd> | Show minimized windows |
| <kbd>Super</kbd>+<kbd>1</kbd>…<kbd>0</kbd> | Workspace (<kbd>Shift</kbd> to move the window) |
| <kbd>Super</kbd>+arrows | Focus (<kbd>Shift</kbd> to move) |
| <kbd>Super</kbd>+<kbd>C</kbd> | Calendar |
| <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>W</kbd> | Wallpaper picker |
| <kbd>Super</kbd>+<kbd>L</kbd> | Lock |
| <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>R</kbd> | Restart the shell |
| <kbd>Print</kbd> / <kbd>Shift</kbd>+<kbd>Print</kbd> | Screenshot region / screen |

In the launcher, right-click an app to add or remove it from Favorites.

## Customizing

- `~/.config/yunyun-syndrome/hypr/user.lua`: monitors, keyboard layout, your own binds.
  Loaded last; reinstalling keeps it.
- `~/.config/yunyun-syndrome/settings.json`: wallpaper, favorites, visualizer and desktop
  decorations on/off, 12/24h clock.
- Titlebars missing after a Hyprland update? Run `yunyun-hyprbars` inside the session.

## For theme developers

The Quickshell frames are rendered from the Plasma SVGs in `../plasma/desktopheme/`
(with the color scheme injected, like Plasma does). After changing those SVGs or the
`.colors` file, regenerate them:

```sh
python3 tools/render-theme-assets.py   # needs rsvg-convert and python-pillow
```

## Credits

- **Miyuki Denpa**: the original YunYun Syndrome KDE Plasma theme (color scheme, Aurorae
  window decoration, Plasma style). The Hyprland version is an adaptation of that work.
- [Candy icons](https://github.com/EliverLara/candy-icons) by EliverLara.
- The game *YunYun Syndrome!? Rhythm Psychosis*, which inspired the original theme.
- Built on [Hyprland](https://hypr.land), [Quickshell](https://quickshell.org),
  [hyprbars](https://github.com/hyprwm/hyprland-plugins), [cava](https://github.com/karlstav/cava)
  and [adw-gtk3](https://github.com/lassekongo83/adw-gtk3).
