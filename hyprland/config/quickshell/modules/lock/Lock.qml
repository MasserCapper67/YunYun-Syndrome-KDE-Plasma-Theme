import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.services
import qs.theme

// Session lock. State lives here so every screen's lock surface shows the same input.
Scope {
    id: root

    property string password: ""
    property bool busy: false
    property bool failed: false

    function tryUnlock() {
        if (password === "" || busy)
            return;
        busy = true;
        failed = false;
        pam.start();
    }

    onPasswordChanged: if (password !== "") failed = false

    PamContext {
        id: pam

        configDirectory: Quickshell.shellPath("assets/pam")
        config: "password.conf"

        onPamMessage: {
            if (pam.responseRequired)
                pam.respond(root.password);
        }

        onCompleted: result => {
            root.busy = false;
            root.password = "";
            if (result === PamResult.Success)
                ShellState.locked = false;
            else
                root.failed = true;
        }
    }

    WlSessionLock {
        locked: ShellState.locked

        WlSessionLockSurface {
            color: Theme.night

            LockSurface {
                anchors.fill: parent
                lock: root
            }
        }
    }
}
