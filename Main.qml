import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    property var pluginApi: null
    property string currentLyric: "No Lyrics"
    property string lastLyric: ""
    property bool isPlaying: false
    property bool isKnownMusic: false
    property string lastTitle: ""
    property string lastPlayer: ""
    property bool manualRestart: false

    Process {
        id: sptlrxProc
        command: ["sptlrx", "-p", "mpris", "pipe"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const cleanText = data.replace(/\x1B\[[0-9;]*[a-zA-Z]/g, "").trim();

                if (cleanText !== "") {
                    root.isKnownMusic = true;
                    root.lastLyric = cleanText;

                    if (root.isPlaying) {
                        root.currentLyric = cleanText;
                    }
                }
            }
        }

        onExited: (code, status) => {
            // Immediate restart if we triggered it manually (player change)
            if (root.manualRestart) {
                root.manualRestart = false;
                sptlrxProc.running = true;
            } else {
                restartTimer.start();
            }
        }
    }

    Timer {
        id: restartTimer
        interval: 3000
        repeat: false
        onTriggered: sptlrxProc.running = true
    }

    Process {
        id: statusProc
        // Added playerName to the check
        command: ["playerctl", "metadata", "--format", "{{ playerName }}:::{{ status }}:::{{ xesam:artist }}:::{{ xesam:title }}", "-F"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(":::");
                const playerName = parts[0] || "";
                const status = parts[1] || "";
                const artist = parts[2] || "";
                const title = parts[3] || "";

                // Restart lyrics process if player changed
                if (root.lastPlayer !== "" && root.lastPlayer !== playerName) {
                    root.manualRestart = true;
                    sptlrxProc.running = false;
                }
                root.lastPlayer = playerName;

                if (title !== root.lastTitle) {
                    root.lastTitle = title;
                    root.isKnownMusic = (artist.trim() !== "");
                    root.lastLyric = "";
                }

                if (status === "Playing") {
                    root.isPlaying = true;
                    if (root.isKnownMusic && root.lastLyric !== "") {
                        root.currentLyric = root.lastLyric;
                    } else {
                        root.currentLyric = "No lyrics";
                    }
                } else {
                    root.isPlaying = false;
                    if (root.isKnownMusic) {
                        root.currentLyric = "Music paused";
                    } else {
                        root.currentLyric = "No lyrics";
                    }
                }
            }
        }
    }
}
