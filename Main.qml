import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons

Item {
    id: root

    property var pluginApi: null
    property string currentLyric: "No lyrics"
    property string lastLyric: ""
    property bool isPlaying: false
    property bool isKnownMusic: false
    property string lastTitle: ""
    property string lastPlayer: ""
    property bool manualRestart: false
    property bool isLoading: false

    Timer {
        id: loadTimer
        interval: 5000
        repeat: false
        onTriggered: {
            root.isLoading = false;
            if (root.isPlaying) {
                root.currentLyric = "Lyrics not found 🥲";
            }
        }
    }

    Process {
        id: sptlrxProc
        command: ["sptlrx", "-p", "mpris", "pipe"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const cleanText = data.replace(/\x1B\[[0-9;]*[a-zA-Z]/g, "").trim();

                if (cleanText !== "") {
                    loadTimer.stop();
                    root.isLoading = false;
                    root.isKnownMusic = true;
                    root.lastLyric = cleanText;

                    if (root.isPlaying) {
                        root.currentLyric = cleanText;
                    }
                }
            }
        }

        onExited: (code, status) => {
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
        command: ["playerctl", "metadata", "--format", "{{ playerName }}:::{{ status }}:::{{ xesam:artist }}:::{{ xesam:title }}", "-F"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                const parts = data.trim().split(":::");
                const playerName = parts[0] || "";
                const status = parts[1] || "";
                const artist = parts[2] || "";
                const title = parts[3] || "";

                if (status === "" || status === "Stopped") {
                    root.isPlaying = false;
                    root.isLoading = false;
                    loadTimer.stop();
                    root.currentLyric = "No lyrics";
                    return;
                }

                if (root.lastPlayer !== "" && root.lastPlayer !== playerName) {
                    root.manualRestart = true;
                    sptlrxProc.running = false;
                }
                root.lastPlayer = playerName;

                if (title !== root.lastTitle) {
                    root.lastTitle = title;
                    root.isKnownMusic = (artist.trim() !== "");
                    root.lastLyric = "";

                    root.isLoading = true;
                    root.currentLyric = "Wait Loading 🪿";
                    loadTimer.restart();
                }

                if (status === "Playing") {
                    root.isPlaying = true;

                    if (!root.isLoading) {
                        if (root.isKnownMusic && root.lastLyric !== "") {
                            root.currentLyric = root.lastLyric;
                        } else {
                            root.currentLyric = "Lyrics not found 🥲";
                        }
                    }
                } else {
                    root.isPlaying = false;
                    root.isLoading = false;
                    loadTimer.stop();

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
