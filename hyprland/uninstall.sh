#!/usr/bin/env bash
# YunYun Syndrome Hyprland theme - uninstaller
#
# Undoes exactly what install.sh recorded in its manifest: removes the files, folders and
# packages it added, restores the files and settings it changed. Files that were changed
# by something else since the install are left alone (and listed), never overwritten.
#
# usage: uninstall.sh [--dry-run]

set -uo pipefail

STATE="${XDG_DATA_HOME:-$HOME/.local/share}/yunyun-syndrome"
MANIFEST="$STATE/manifest"
DRY_RUN=0
SKIPPED=()

[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=1

c_pink=$'\e[38;2;191;89;210m'
c_lav=$'\e[38;2;138;140;240m'
c_dim=$'\e[38;2;127;98;211m'
c_off=$'\e[0m'

say() { printf '%s\n' "${c_lav}::${c_off} $*"; }
note() { printf '%s\n' "   ${c_dim}$*${c_off}"; }
warn() { printf '%s\n' "${c_pink}!!${c_off} $*" >&2; }

confirm() {
    local default="${2:-y}" hint="[Y/n]"
    [[ "$default" == n ]] && hint="[y/N]"
    read -r -p "${c_lav}?? ${c_off}$1 $hint " REPLY || true
    REPLY="${REPLY:-$default}"
    [[ "$REPLY" =~ ^[Yy] ]]
}

run() {
    if ((DRY_RUN)); then
        note "would run: $*"
    else
        "$@"
    fi
}

hash() { sha256sum "$1" 2>/dev/null | cut -d' ' -f1; }

# Never touch anything outside the user's home, except the root paths install.sh created
safe_user_path() {
    [[ "$1" == "$HOME"/* && "$1" != "$HOME" && "$1" != "$HOME/" ]]
}

records() { # records <type>: print the fields of every record of this type, newest first
    tac "$MANIFEST" | awk -F'\t' -v t="$1" '$1 == t' | cut -f2-
}

if [[ $EUID -eq 0 ]]; then
    warn "Run this as your normal user, not root."
    exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
    warn "YunYun Syndrome doesn't seem to be installed (no $MANIFEST)."
    exit 1
fi

if [[ "${YUNYUN_SESSION:-}" == 1 ]]; then
    warn "You are inside the YunYun session. Log into another session first, then run this again."
    ((DRY_RUN)) || exit 1
fi

echo
say "${c_pink}YunYun Syndrome${c_off} - uninstall"
note "Hyprland adaptation of the KDE theme by Miyuki Denpa."
echo
say "This will:"
note "remove the YunYun login session and its config ($(records dir | wc -l) folders, $(records file | wc -l) files)"
note "restore $(records backup | wc -l) file(s) and $(records gsetting | wc -l) setting(s) changed by the installer"
(($(records hyprpm | wc -l))) && note "remove the hyprland-plugins repository from hyprpm"
note "offer to remove the $(records pkg | wc -l) package(s) it installed"
echo
confirm "Continue?" || exit 0

# 1. Settings changed in your normal GSettings database
while IFS=$'\t' read -r schema key old; do
    [[ -n "$schema" ]] || continue
    say "Restoring $schema $key"
    if [[ -z "$old" ]]; then
        run gsettings reset "$schema" "$key" || SKIPPED+=("gsetting $schema $key")
    else
        run gsettings set "$schema" "$key" "$old" || SKIPPED+=("gsetting $schema $key")
    fi
done < <(records gsetting)

# 2. Files the installer replaced or created in your config: only if they're still ours
while IFS=$'\t' read -r path backup sum; do
    [[ -n "$path" ]] || continue
    if ! safe_user_path "$path"; then
        SKIPPED+=("$path (outside home)")
        continue
    fi
    if [[ -e "$path" && "$(hash "$path")" != "$sum" ]]; then
        warn "$path was changed after the install: left as is."
        note "Your original is still at $backup"
        SKIPPED+=("$path (changed since install, original kept at $backup)")
        KEEP_BACKUPS=1
        continue
    fi
    say "Restoring $path"
    run cp -a "$backup" "$path"
done < <(records backup)

while IFS=$'\t' read -r path sum; do
    [[ -n "$path" ]] || continue
    safe_user_path "$path" || continue
    [[ -e "$path" ]] || continue
    if [[ "$(hash "$path")" != "$sum" ]]; then
        warn "$path was changed after the install: left as is."
        SKIPPED+=("$path (changed since install)")
        continue
    fi
    say "Removing $path"
    run rm -f "$path"
done < <(records created)

# 3. Files and folders the installer created
while IFS=$'\t' read -r path; do
    [[ -n "$path" ]] || continue
    safe_user_path "$path" || continue
    [[ -e "$path" ]] || continue
    say "Removing $path"
    run rm -f "$path"
done < <(records file)

while IFS=$'\t' read -r path; do
    [[ -n "$path" ]] || continue
    safe_user_path "$path" || continue
    [[ -e "$path" ]] || continue
    say "Removing $path"
    run rm -rf "$path"
done < <(records dir)

# Parent folders the installer had to create, deepest first, only if nothing else is in them.
# Run again at the very end, once the installer's own state folder is gone.
mapfile -t emptydirs < <(records emptydir | awk '{ print gsub("/", "/") "\t" $0 }' | sort -rn | cut -f2-)
remove_empty_parents() {
    local path
    for path in "${emptydirs[@]}"; do
        safe_user_path "$path" || continue
        [[ -d "$path" ]] || continue
        if ((DRY_RUN)); then
            note "would remove $path if empty"
        else
            rmdir "$path" 2>/dev/null && say "Removing empty $path"
        fi
    done
    return 0
}
remove_empty_parents

# 4. hyprpm repository (and the header cache, if the installer created it)
while IFS=$'\t' read -r repo; do
    [[ -n "$repo" ]] || continue
    if command -v hyprpm >/dev/null; then
        say "Removing $repo from hyprpm"
        run hyprpm remove "$repo" || SKIPPED+=("hyprpm repository $repo")
    fi
done < <(records hyprpm)

# 5. Root files: the login session
mapfile -t rootfiles < <(records rootfile)
mapfile -t rootdirs < <(records rootdir)
if ((${#rootfiles[@]} + ${#rootdirs[@]})); then
    say "Removing the login session and system files (needs sudo)"
    for path in "${rootfiles[@]}"; do
        case "$path" in
            /usr/local/bin/yunyun-syndrome-session | /usr/share/wayland-sessions/yunyun-syndrome.desktop)
                run sudo rm -f "$path" || SKIPPED+=("$path")
                ;;
            *) SKIPPED+=("$path (unexpected root file)") ;;
        esac
    done
    for path in "${rootdirs[@]}"; do
        case "$path" in
            /var/cache/hyprpm/"$USER")
                run sudo rm -rf "$path" || SKIPPED+=("$path")
                ;;
            *) SKIPPED+=("$path (unexpected root folder)") ;;
        esac
    done
fi

# 6. Packages
mapfile -t pkgs < <(records pkg | while read -r p; do pacman -Qq "$p" 2>/dev/null; done)
if ((${#pkgs[@]})); then
    echo
    say "The installer added these packages:"
    note "${pkgs[*]}"
    note "If you started using some of them yourself, answer no and remove the rest by hand."
    if confirm "Remove them (with dependencies nothing else needs)?"; then
        if ! run sudo pacman -Rns "${pkgs[@]}"; then
            # Some are needed by other packages now: remove the others one by one
            for p in "${pkgs[@]}"; do
                run sudo pacman -Rns --noconfirm "$p" &>/dev/null || SKIPPED+=("package $p (needed by something else)")
            done
        fi
    else
        SKIPPED+=("packages: ${pkgs[*]}")
    fi
fi

# 7. The installer's own state
if ((DRY_RUN)); then
    note "would remove $STATE"
elif [[ -n "${KEEP_BACKUPS:-}" ]]; then
    rm -f "$MANIFEST" "$STATE/uninstall.sh" "$STATE/theming-mode"
    note "Kept $STATE/backups (some originals could not be restored)."
else
    rm -rf "$STATE"
fi
remove_empty_parents

echo
if ((${#SKIPPED[@]})); then
    say "Done, except for:"
    for s in "${SKIPPED[@]}"; do
        note "- $s"
    done
else
    say "YunYun Syndrome is fully removed. Thanks for trying it!"
fi
