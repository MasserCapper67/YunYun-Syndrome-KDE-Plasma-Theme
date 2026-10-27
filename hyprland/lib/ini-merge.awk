# Merge INI overrides into an existing INI file, keeping everything else as is.
# usage: awk -f ini-merge.awk OVERRIDES TARGET > merged
#
# Keys from OVERRIDES replace the same key in the same [group] of TARGET; keys and groups
# missing from TARGET are added at the end of their group / of the file.

function flush(group,    i, k) {
    for (i = 1; i <= nkeys[group]; i++) {
        k = keyorder[group, i]
        if (!((group, k) in done)) {
            print k "=" ov[group, k]
            done[group, k] = 1
        }
    }
}

FNR == NR {
    if ($0 ~ /^\[.*\]$/) {
        g = $0
        if (!(g in known)) {
            known[g] = 1
            groups[++ngroups] = g
        }
    } else if ($0 ~ /^[^#;][^=]*=/) {
        k = substr($0, 1, index($0, "=") - 1)
        if (!((g, k) in ov))
            keyorder[g, ++nkeys[g]] = k
        ov[g, k] = substr($0, index($0, "=") + 1)
    }
    next
}

# Blank lines are held back so added keys end up before the gap between groups
function blanks() {
    while (pending > 0) {
        print ""
        pending--
    }
}

{
    if ($0 ~ /^[ \t]*$/) {
        pending++
        next
    }
    if ($0 ~ /^\[.*\]$/) {
        flush(current)
        blanks()
        current = $0
        present[current] = 1
        print
        next
    }
    blanks()
    if ($0 ~ /^[^#;][^=]*=/) {
        k = substr($0, 1, index($0, "=") - 1)
        if ((current, k) in ov) {
            print k "=" ov[current, k]
            done[current, k] = 1
            next
        }
    }
    print
}

END {
    flush(current)
    blanks()
    for (i = 1; i <= ngroups; i++) {
        g = groups[i]
        if (!(g in present)) {
            if (FNR > 0 && FILENAME != ARGV[1])
                print ""
            print g
            flush(g)
        }
    }
}
