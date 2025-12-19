import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    property var pluginApi: null
    property string currentLyric: "No Lyrics"

    // Process to run sptlrx in pipe mode
    Process {
        id: sptlrxProc
        command: ["sptlrx", "pipe"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                // Strip ANSI escape codes
                const cleanText = data.replace(/\x1B\[[0-9;]*[a-zA-Z]/g, "").trim();
                if (cleanText !== "") {
                    root.currentLyric = cleanText;
                }
            }
        }

        onExited: (code, status) => {
            Logger.w("Lyrics", "sptlrx process exited. Restarting in 3s...");
            restartTimer.start();
        }
    }

    Timer {
        id: restartTimer
        interval: 3000
        repeat: false
        onTriggered: sptlrxProc.running = true
    }
}
