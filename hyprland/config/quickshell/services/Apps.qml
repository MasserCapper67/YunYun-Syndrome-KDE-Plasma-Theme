pragma Singleton

import QtQuick
import Quickshell

// Installed applications, grouped like the KDE launcher's categories
Singleton {
    id: root

    readonly property var all: DesktopEntries.applications.values.filter(e => !e.noDisplay).sort((a, b) => a.name.localeCompare(b.name))

    // Freedesktop main categories, in the order the KDE launcher shows them
    readonly property var categoryDefs: [
        { id: "Development", name: "Development", icon: "applications-development", match: ["Development"] },
        { id: "Education", name: "Education", icon: "applications-education", match: ["Education", "Science"] },
        { id: "Game", name: "Games", icon: "applications-games", match: ["Game"] },
        { id: "Graphics", name: "Graphics", icon: "applications-graphics", match: ["Graphics"] },
        { id: "Network", name: "Internet", icon: "applications-internet", match: ["Network"] },
        { id: "AudioVideo", name: "Multimedia", icon: "applications-multimedia", match: ["AudioVideo", "Audio", "Video"] },
        { id: "Office", name: "Office", icon: "applications-office", match: ["Office"] },
        { id: "Settings", name: "Settings", icon: "preferences-system", match: ["Settings"] },
        { id: "System", name: "System", icon: "applications-system", match: ["System"] },
        { id: "Utility", name: "Utilities", icon: "applications-utilities", match: ["Utility"] },
    ]

    // Only categories that have at least one app, plus "Lost & Found" for the rest
    readonly property var categories: {
        const out = categoryDefs.filter(c => all.some(e => inCategory(e, c)));
        if (all.some(e => !categoryDefs.some(c => inCategory(e, c))))
            out.push({ id: "Other", name: "Lost & Found", icon: "applications-other", match: [] });
        return out;
    }

    function inCategory(entry, category) {
        if (category.id === "Other")
            return !categoryDefs.some(c => inCategory(entry, c));
        return entry.categories.some(c => category.match.includes(c));
    }

    function byCategory(id) {
        const category = categories.find(c => c.id === id);
        return category ? all.filter(e => inCategory(e, category)) : [];
    }

    function byIds(ids) {
        return ids.map(id => DesktopEntries.byId(id)).filter(e => e !== null);
    }

    function search(text) {
        const q = text.trim().toLowerCase();
        if (!q)
            return [];
        const scored = [];
        for (const e of all) {
            const name = e.name.toLowerCase();
            let score = 0;
            if (name.startsWith(q))
                score = 100;
            else if (name.split(/\s+/).some(w => w.startsWith(q)))
                score = 80;
            else if (name.includes(q))
                score = 60;
            else if ((e.genericName || "").toLowerCase().includes(q))
                score = 40;
            else if (e.keywords.some(k => k.toLowerCase().includes(q)))
                score = 30;
            else if ((e.comment || "").toLowerCase().includes(q) || e.id.toLowerCase().includes(q))
                score = 20;
            if (score > 0)
                scored.push({ entry: e, score: score });
        }
        scored.sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name));
        return scored.slice(0, 50).map(s => s.entry);
    }

    function launch(entry) {
        if (!entry)
            return;
        if (entry.runInTerminal)
            Quickshell.execDetached(["kitty", "-e", ...entry.command]);
        else
            entry.execute();
    }

    // First run: favorite a terminal, file manager and browser if they exist
    function defaultFavorites() {
        const groups = [
            ["kitty"],
            ["org.kde.dolphin", "org.gnome.Nautilus", "thunar", "pcmanfm-qt", "nemo"],
            ["firefox", "zen", "zen-browser", "chromium", "google-chrome", "brave-browser", "librewolf"],
            ["systemsettings", "org.gnome.Settings", "nwg-look"],
        ];
        const out = [];
        for (const group of groups) {
            const hit = group.find(id => DesktopEntries.byId(id) !== null);
            if (hit)
                out.push(hit);
        }
        return out;
    }
}
