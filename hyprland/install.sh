#!/usr/bin/env bash
# YunYun Syndrome!? Rhythm Psychosis - Hyprland theme installer for Arch Linux
#
# Installs the theme as its own login session ("Hyprland (YunYun Syndrome)"), next to
# whatever desktop you already use. Everything it installs or changes is written to a
# manifest, so uninstall.sh can remove exactly that and restore what was there before.
#
# usage: ./install.sh [--dry-run]

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/yunyun-syndrome"
STATE="${XDG_DATA_HOME:-$HOME/.local/share}/yunyun-syndrome"
MANIFEST="$STATE/manifest"
BACKUPS="$STATE/backups"
DRY_RUN=0

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

PACKAGES=(
    # compositor + titlebar plugin build tools
    hyprland hyprpm xdg-desktop-portal-hyprland xdg-desktop-portal-gtk hyprpolkitagent
    git base-devel cmake meson cpio pkgconf
    # shell
    quickshell qt6-svg qt6-imageformats cava
    # terminal
    kitty fastfetch starship
    # fonts and app theming
    ttf-fira-sans ttf-jetbrains-mono-nerd adw-gtk-theme dconf
    # helpers used by keybinds and the shell
    wl-clipboard grim slurp libnotify xdg-utils xdg-user-dirs wireplumber playerctl brightnessctl
)

# --- output -------------------------------------------------------------------------------

c_pink=$'\e[38;2;191;89;210m'
c_lav=$'\e[38;2;138;140;240m'
c_dim=$'\e[38;2;127;98;211m'
c_off=$'\e[0m'

say() { printf '%s\n' "${c_lav}::${c_off} $*"; }
note() { printf '%s\n' "   ${c_dim}$*${c_off}"; }
warn() { printf '%s\n' "${c_pink}!!${c_off} $*" >&2; }
die() {
    warn "$*"
    exit 1
}

ask() { # ask "question" default -> REPLY
    local prompt="$1" default="${2:-}"
    read -r -p "${c_lav}?? ${c_off}${prompt}${default:+ [$default]} " REPLY || true
    REPLY="${REPLY:-$default}"
}

confirm() { # confirm "question" [y|n]
    local default="${2:-y}" hint="[Y/n]"
    [[ "$default" == n ]] && hint="[y/N]"
    read -r -p "${c_lav}?? ${c_off}$1 $hint " REPLY || true
    REPLY="${REPLY:-$default}"
    [[ "$REPLY" =~ ^[Yy] ]]
}

run() { # run a command, or only print it with --dry-run
    if ((DRY_RUN)); then
        note "would run: $*"
    else
        "$@"
    fi
}

banner() {
    printf '%s\n' "$c_pink"
    cat <<'EOF'
  ██╗   ██╗██╗   ██╗███╗   ██╗██╗   ██╗██╗   ██╗███╗   ██╗
  ╚██╗ ██╔╝██║   ██║████╗  ██║╚██╗ ██╔╝██║   ██║████╗  ██║
   ╚████╔╝ ██║   ██║██╔██╗ ██║ ╚████╔╝ ██║   ██║██╔██╗ ██║
    ╚██╔╝  ██║   ██║██║╚██╗██║  ╚██╔╝  ██║   ██║██║╚██╗██║
     ██║   ╚██████╔╝██║ ╚████║   ██║   ╚██████╔╝██║ ╚████║
     ╚═╝    ╚═════╝ ╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝  ╚═══╝
EOF
    printf '%s\n' "$c_off"
    printf '%s\n' "  ${c_lav}YunYun Syndrome!? Rhythm Psychosis${c_off} - Hyprland theme" ""
    printf '%s\n' "  ${c_dim}Original KDE Plasma theme (colors, window decoration, Plasma style)"
    printf '%s\n' "  by ${c_pink}Miyuki Denpa${c_dim}, licensed GPL-2.0+. This Hyprland version is"
    printf '%s\n' "  an adaptation of their work: all credit for the design goes to them."
    printf '%s\n' "  Candy icons by EliverLara (GPL-3.0).${c_off}" ""
}

# --- manifest -----------------------------------------------------------------------------
# One record per line, tab separated:
#   pkg       <name>                         pacman package installed by us
#   dir       <path>                         directory we created
#   emptydir  <path>                         parent directory we created; removed if empty
#   file      <path>                         file we created
#   rootfile  <path>                         file we created as root
#   rootdir   <path>                         directory we created as root
#   backup    <path> <backup> <sha256>       file we replaced; restored if still ours
#   created   <path> <sha256>                file we wrote where none existed; deleted if still ours
#   gsetting  <schema> <key> <old value>     GSettings value we changed (empty: was unset)
#   hyprpm    <repo>                         hyprpm repository we added

record() {
    ((DRY_RUN)) && return 0
    local line
    line="$(printf '%s\t' "$@")"
    line="${line%$'\t'}"
    grep -qxF -- "$line" "$MANIFEST" 2>/dev/null || printf '%s\n' "$line" >>"$MANIFEST"
}

recorded() { # recorded <type> <path>: is there a record of this type for this path?
    [[ -f "$MANIFEST" ]] && awk -F'\t' -v t="$1" -v p="$2" '$1 == t && $2 == p { found = 1 } END { exit !found }' "$MANIFEST"
}

forget() { # forget <type> <path>: drop the records of this type for this path
    ((DRY_RUN)) && return 0
    [[ -f "$MANIFEST" ]] || return 0
    awk -F'\t' -v t="$1" -v p="$2" '!($1 == t && $2 == p)' "$MANIFEST" >"$MANIFEST.tmp"
    mv "$MANIFEST.tmp" "$MANIFEST"
}

hash() { sha256sum "$1" | cut -d' ' -f1; }

# Parent folders that don't exist yet: uninstall removes them again if they're empty
track_parents() {
    local dir
    dir="$(dirname "$1")"
    while [[ ! -e "$dir" && "$dir" == "$HOME"/* ]]; do
        record emptydir "$dir"
        dir="$(dirname "$dir")"
    done
}

# Remember a path that doesn't exist yet, so uninstall removes it (dir or file)
track_new() {
    local type="$1" path="$2"
    if [[ ! -e "$path" ]]; then
        track_parents "$path"
        record "$type" "$path"
    fi
}

# Write $src to a user-owned path outside our folders, backing up what was there.
# On reinstall the original backup is kept; only the recorded hash is updated.
install_managed() {
    local src="$1" dest="$2" backup
    if ((DRY_RUN)); then
        [[ -e "$dest" ]] && note "would back up and replace $dest" || note "would create $dest"
        return 0
    fi
    track_parents "$dest"
    mkdir -p "$(dirname "$dest")"
    if recorded backup "$dest"; then
        backup="$(awk -F'\t' -v p="$dest" '$1 == "backup" && $2 == p { print $3 }' "$MANIFEST" | tail -1)"
        cp -f "$src" "$dest"
        forget backup "$dest"
        record backup "$dest" "$backup" "$(hash "$dest")"
    elif recorded created "$dest"; then
        cp -f "$src" "$dest"
        forget created "$dest"
        record created "$dest" "$(hash "$dest")"
    elif [[ -e "$dest" ]]; then
        backup="$BACKUPS/$(printf '%s' "${dest#/}" | tr '/' '%')"
        mkdir -p "$BACKUPS"
        cp -a "$dest" "$backup"
        cp -f "$src" "$dest"
        record backup "$dest" "$backup" "$(hash "$dest")"
    else
        cp -f "$src" "$dest"
        record created "$dest" "$(hash "$dest")"
    fi
}

set_gsetting() { # set_gsetting <schema> <key> <value> [dconf profile]
    local schema="$1" key="$2" value="$3" profile="${4:-}" old
    if [[ -z "$profile" ]]; then
        # The raw dconf value is empty when the key was never set: uninstall then resets it
        old="$(dconf read "/${schema//.//}/$key" 2>/dev/null || true)"
        if ! awk -F'\t' -v s="$schema" -v k="$key" '$1 == "gsetting" && $2 == s && $3 == k { f = 1 } END { exit !f }' "$MANIFEST" 2>/dev/null; then
            record gsetting "$schema" "$key" "$old"
        fi
        run gsettings set "$schema" "$key" "$value"
    else
        run env DCONF_PROFILE="$profile" gsettings set "$schema" "$key" "$value"
    fi
}

# --- steps --------------------------------------------------------------------------------

preflight() {
    [[ $EUID -ne 0 ]] || die "Run this as your normal user, not root (it asks for sudo when needed)."
    command -v pacman >/dev/null || die "This installer is for Arch Linux (pacman not found)."
    [[ -f "$REPO/config/hypr/hyprland.lua" ]] || die "Run install.sh from the theme's hyprland/ folder."
    if [[ "${YUNYUN_SESSION:-}" == 1 ]]; then
        warn "You are inside the YunYun session. Reinstalling works, but restart the session afterwards."
    fi
}

ask_questions() {
    if [[ -f "$MANIFEST" ]]; then
        say "YunYun Syndrome is already installed: this will update it."
        note "Your hypr/user.lua and settings.json are kept."
        REINSTALL=1
    else
        REINSTALL=0
    fi

    echo
    say "Wallpaper"
    note "The theme doesn't ship one: pick any image (png/jpg/webp, or an animated gif)."
    note "Leave empty to choose later with Super+Shift+W or the desktop's picture icon."
    while true; do
        ask "Path to the wallpaper:" ""
        WALLPAPER="${REPLY/#\~/$HOME}"
        [[ -z "$WALLPAPER" || -f "$WALLPAPER" ]] && break
        warn "No file at '$WALLPAPER'."
    done
    [[ -n "$WALLPAPER" ]] && WALLPAPER="$(realpath "$WALLPAPER")"

    echo
    say "Fastfetch logo"
    note "Image shown next to fastfetch in kitty (the screenshots use a chibi YunYun)."
    note "Leave empty for the Arch logo."
    while true; do
        ask "Path to the logo image:" ""
        LOGO="${REPLY/#\~/$HOME}"
        [[ -z "$LOGO" || -f "$LOGO" ]] && break
        warn "No file at '$LOGO'."
    done
    [[ -n "$LOGO" ]] && LOGO="$(realpath "$LOGO")"

    echo
    say "App theming (GTK and Qt apps, icons)"
    note "1) Only in the YunYun session (recommended): your other sessions keep their look."
    note "   libadwaita apps (GNOME apps) and some KDE apps stay partly unthemed."
    note "2) Everywhere: exact look, but also changes your other sessions' app theme."
    note "   Your current settings are backed up and restored by uninstall.sh."
    while true; do
        ask "Choose 1 or 2:" "1"
        [[ "$REPLY" == 1 || "$REPLY" == 2 ]] && break
    done
    THEMING="session"
    [[ "$REPLY" == 2 ]] && THEMING="global"

    local previous
    previous="$(cat "$STATE/theming-mode" 2>/dev/null || true)"
    if [[ -n "$previous" && "$previous" != "$THEMING" ]]; then
        die "The theme was installed with '$previous' app theming. Run uninstall.sh first to switch."
    fi
    return 0
}

install_packages() {
    local wanted=("${PACKAGES[@]}") missing=()
    [[ "$THEMING" == global ]] && wanted+=(qt6ct)

    # pacman -T understands "provides", so e.g. an already installed nerd-fonts bundle counts
    mapfile -t missing < <(pacman -T "${wanted[@]}" || true)

    echo
    if ((${#missing[@]} == 0)); then
        say "All required packages are already installed."
        return 0
    fi
    say "These packages will be installed with pacman:"
    note "${missing[*]}"
    note "uninstall.sh removes them again (and dependencies nothing else needs)."
    confirm "Install them now?" || die "Cancelled, nothing was installed."
    run sudo pacman -S --needed "${missing[@]}"
    for pkg in "${missing[@]}"; do
        # only record what really got installed (pacman may resolve a provider instead)
        if ((DRY_RUN)) || pacman -Qq "$pkg" &>/dev/null; then
            record pkg "$pkg"
        fi
    done
}

install_icons() {
    local dir="${XDG_DATA_HOME:-$HOME/.local/share}/icons/candy-icons"
    if [[ -d "$dir" || -d /usr/share/icons/candy-icons ]]; then
        say "Candy icons are already installed."
        return 0
    fi
    say "Downloading Candy icons..."
    track_new dir "$dir"
    run git clone --depth 1 https://github.com/EliverLara/candy-icons.git "$dir"
    run rm -rf "$dir/.git"
}

# Directories programs create on first run. Recorded only if they don't exist yet,
# so uninstall never deletes something that was already yours.
track_runtime_dirs() {
    local cache="${XDG_CACHE_HOME:-$HOME/.cache}" data="${XDG_DATA_HOME:-$HOME/.local/share}"
    local state="${XDG_STATE_HOME:-$HOME/.local/state}" config="${XDG_CONFIG_HOME:-$HOME/.config}"
    local d
    for d in "$cache/yunyun-syndrome" "$state/yunyun-syndrome" \
        "$cache/quickshell" "$data/quickshell" "$state/quickshell" \
        "$cache/starship" "$cache/fastfetch" "$config/cava" \
        "$cache/hyprland" "$data/hyprland" "$state/hyprland" "$cache/kitty" \
        "$config/dconf/yunyun-syndrome"; do
        if [[ "$d" == */dconf/* ]]; then
            track_new file "$d"
        else
            track_new dir "$d"
        fi
    done
}

detect_keyboard() {
    KB_LAYOUT="$(localectl status 2>/dev/null | awk -F': *' '/X11 Layout/ { print $2 }')"
    KB_VARIANT="$(localectl status 2>/dev/null | awk -F': *' '/X11 Variant/ { print $2 }')"
    KB_LAYOUT="${KB_LAYOUT:-us}"
}

json_escape() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }

install_config() {
    say "Installing the theme to $CFG"
    track_new dir "$CFG"
    if ((DRY_RUN)); then
        note "would copy $REPO/config to $CFG"
        return 0
    fi

    mkdir -p "$CFG"
    # Keep the user's own files on reinstall
    local keep
    keep="$(mktemp -d)"
    for f in hypr/user.lua hypr/generated.lua settings.json; do
        [[ -f "$CFG/$f" ]] && install -D "$CFG/$f" "$keep/$f"
    done
    cp -rT "$REPO/config" "$CFG"
    rm -f "$CFG/hypr/user.lua"
    cp -rT "$keep" "$CFG"
    rm -rf "$keep"
    chmod +x "$CFG"/bin/*

    if [[ ! -f "$CFG/hypr/user.lua" ]]; then
        detect_keyboard
        sed -e "s|@KB_LAYOUT@|$KB_LAYOUT|" -e "s|@KB_VARIANT@|$KB_VARIANT|" \
            "$REPO/config/hypr/user.lua" >"$CFG/hypr/user.lua"
        note "Keyboard layout: $KB_LAYOUT${KB_VARIANT:+ ($KB_VARIANT)} (change it in $CFG/hypr/user.lua)"
    fi

    local logo='{ "source": "arch" }'
    if [[ -n "$LOGO" ]]; then
        logo="{ \"type\": \"kitty\", \"source\": \"$(json_escape "$LOGO")\", \"width\": 28, \"padding\": { \"top\": 1, \"right\": 4 } }"
    fi
    awk -v logo="$logo" '{ sub(/@LOGO@/, logo) } 1' "$REPO/config/fastfetch/config.jsonc" >"$CFG/fastfetch/config.jsonc"

    local pictures dirs
    pictures="$(xdg-user-dir PICTURES 2>/dev/null || true)"
    # xdg-user-dir answers $HOME when no Pictures folder is configured
    [[ -z "$pictures" || "$pictures" == "$HOME" ]] && pictures="$HOME/Pictures"
    if [[ ! -f "$CFG/settings.json" ]]; then
        dirs="\"$(json_escape "$pictures/Wallpapers")\", \"$(json_escape "$pictures")\""
        [[ -n "$WALLPAPER" ]] && dirs="\"$(json_escape "$(dirname "$WALLPAPER")")\", $dirs"
        cat >"$CFG/settings.json" <<EOF
{
    "wallpaper": "$(json_escape "$WALLPAPER")",
    "wallpaperDirs": [$dirs],
    "favorites": [],
    "favoritesInitialized": false,
    "visualizer": true,
    "desktopDecorations": true,
    "clock24h": true
}
EOF
    elif [[ -n "$WALLPAPER" ]]; then
        local escaped
        escaped="$(json_escape "$WALLPAPER" | sed 's/[&|]/\\&/g')"
        sed -i "s|^\(\s*\"wallpaper\":\s*\)\".*\"|\1\"$escaped\"|" "$CFG/settings.json"
    fi
}

install_gtk_theme() {
    local dir="${XDG_DATA_HOME:-$HOME/.local/share}/themes/YunYunSyndrome"
    track_new dir "$dir"
    run mkdir -p "$dir"
    run cp -rT "$REPO/theming/gtk/YunYunSyndrome" "$dir"
}

theming_session() {
    say "App theming: YunYun session only"
    local profile="$CFG/dconf/profile"
    run mkdir -p "$CFG/dconf"
    ((DRY_RUN)) || printf 'user-db:yunyun-syndrome\n' >"$profile"

    # Start the session's own GSettings database from a copy of your current settings
    if ! recorded seeded "$profile"; then
        if ((DRY_RUN)); then
            note "would copy your GSettings into the YunYun session's database"
        else
            dconf dump / | DCONF_PROFILE="$profile" dconf load / || warn "Could not copy your GSettings."
            record seeded "$profile"
        fi
    fi
    set_gsetting org.gnome.desktop.interface gtk-theme "YunYunSyndrome" "$profile"
    set_gsetting org.gnome.desktop.interface icon-theme "candy-icons" "$profile"
    set_gsetting org.gnome.desktop.interface font-name "Fira Sans 10" "$profile"
    set_gsetting org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 10" "$profile"
    set_gsetting org.gnome.desktop.interface color-scheme "prefer-dark" "$profile"

    ((DRY_RUN)) || cat >"$CFG/theming.env" <<EOF
# Read by yunyun-syndrome-session: app theming only inside the YunYun session
GTK_THEME=YunYunSyndrome
DCONF_PROFILE=$profile
QT_QPA_PLATFORMTHEME=gtk3
EOF
}

theming_global() {
    say "App theming: everywhere (backing up your current settings)"
    local config="${XDG_CONFIG_HOME:-$HOME/.config}" data="${XDG_DATA_HOME:-$HOME/.local/share}"
    local tmp
    tmp="$(mktemp -d)"

    # libadwaita apps
    install_managed "$REPO/theming/gtk/libadwaita-gtk.css" "$config/gtk-4.0/gtk.css"

    # Qt apps through qt6ct
    install_managed "$REPO/theming/qt6ct/colors/YunYunSyndrome.conf" "$config/qt6ct/colors/YunYunSyndrome.conf"
    cat >"$tmp/qt6ct.ini" <<EOF
[Appearance]
color_scheme_path=$config/qt6ct/colors/YunYunSyndrome.conf
custom_palette=true
icon_theme=candy-icons
style=Fusion
EOF
    touch "$tmp/current-qt6ct.conf"
    [[ -f "$config/qt6ct/qt6ct.conf" ]] && cp "$config/qt6ct/qt6ct.conf" "$tmp/current-qt6ct.conf"
    awk -f "$REPO/lib/ini-merge.awk" "$tmp/qt6ct.ini" "$tmp/current-qt6ct.conf" >"$tmp/qt6ct.conf"
    install_managed "$tmp/qt6ct.conf" "$config/qt6ct/qt6ct.conf"

    # KDE apps (Dolphin, Kate...) read colors and icons from kdeglobals
    install_managed "$REPO/../color-schemes/YunYunSyndrome.colors" "$data/color-schemes/YunYunSyndrome.colors"
    {
        # the scheme's own [General] (Name, shadeSortColumn) doesn't belong in kdeglobals
        awk '/^\[/ { skip = ($0 == "[General]") } !skip' "$REPO/../color-schemes/YunYunSyndrome.colors"
        printf '\n[General]\nColorScheme=YunYunSyndrome\n\n[Icons]\nTheme=candy-icons\n'
    } >"$tmp/kde.ini"
    touch "$tmp/current-kdeglobals"
    [[ -f "$config/kdeglobals" ]] && cp "$config/kdeglobals" "$tmp/current-kdeglobals"
    awk -f "$REPO/lib/ini-merge.awk" "$tmp/kde.ini" "$tmp/current-kdeglobals" >"$tmp/kdeglobals"
    install_managed "$tmp/kdeglobals" "$config/kdeglobals"
    rm -rf "$tmp"

    # GTK apps
    set_gsetting org.gnome.desktop.interface gtk-theme "YunYunSyndrome"
    set_gsetting org.gnome.desktop.interface icon-theme "candy-icons"
    set_gsetting org.gnome.desktop.interface font-name "Fira Sans 10"
    set_gsetting org.gnome.desktop.interface monospace-font-name "JetBrainsMono Nerd Font 10"
    set_gsetting org.gnome.desktop.interface color-scheme "prefer-dark"

    ((DRY_RUN)) || cat >"$CFG/theming.env" <<EOF
# Read by yunyun-syndrome-session: apps use the global theme set up by install.sh
QT_QPA_PLATFORMTHEME=qt6ct
EOF
}

install_hyprbars() {
    echo
    say "Titlebars (hyprbars plugin)"
    note "hyprpm downloads the Hyprland headers and builds the plugin. It will ask for sudo."
    note "The plugin is only loaded by the YunYun session, never by your other Hyprland configs."
    if ((DRY_RUN)); then
        note "would run: $CFG/bin/yunyun-hyprbars"
        return 0
    fi
    if ! "$CFG/bin/yunyun-hyprbars"; then
        warn "Building hyprbars failed. The session works without titlebars;"
        warn "run 'yunyun-hyprbars' from inside the session to try again."
    fi
}

install_session() {
    say "Adding the login session (needs sudo)"
    local bin=/usr/local/bin/yunyun-syndrome-session desktop=/usr/share/wayland-sessions/yunyun-syndrome.desktop
    [[ -e "$bin" ]] || record rootfile "$bin"
    [[ -e "$desktop" ]] || record rootfile "$desktop"
    run sudo install -Dm755 "$REPO/session/yunyun-syndrome-session" "$bin"
    run sudo install -Dm644 "$REPO/session/yunyun-syndrome.desktop" "$desktop"
}

main() {
    banner
    preflight
    ask_questions

    if ((DRY_RUN)); then
        say "Dry run: nothing will be changed."
    else
        local parents=() d
        d="$(dirname "$STATE")"
        while [[ ! -e "$d" && "$d" == "$HOME"/* ]]; do
            parents+=("$d")
            d="$(dirname "$d")"
        done
        mkdir -p "$STATE"
        touch "$MANIFEST"
        for d in "${parents[@]}"; do
            record emptydir "$d"
        done
    fi
    track_runtime_dirs

    install_packages
    install_icons
    install_config
    install_gtk_theme
    if [[ "$THEMING" == global ]]; then
        theming_global
    else
        theming_session
    fi
    install_session
    install_hyprbars

    if ((!DRY_RUN)); then
        cp -f "$REPO/uninstall.sh" "$STATE/uninstall.sh"
        chmod +x "$STATE/uninstall.sh"
        printf '%s\n' "$THEMING" >"$STATE/theming-mode"
    fi

    echo
    say "Done! Log out and pick ${c_pink}Hyprland (YunYun Syndrome)${c_off} in your login screen."
    note "Super+Space launcher · Super+Return kitty · Super+L lock · Super+Shift+W wallpaper"
    note "Your settings: $CFG/hypr/user.lua and $CFG/settings.json"
    note "Uninstall: $STATE/uninstall.sh"
}

main "$@"
