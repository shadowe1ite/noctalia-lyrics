import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import qs.Commons
import qs.Widgets
import qs.Services.UI

Rectangle {
    id: root

    property var pluginApi: null
    property var backend: pluginApi?.mainInstance
    property string lyricText: backend?.currentLyric || "No Lyrics"

    // Settings with fallbacks
    property int widgetWidth: pluginApi?.pluginSettings?.widgetWidth ?? 300
    property int scrollSpeed: pluginApi?.pluginSettings?.scrollSpeed ?? 50
    property string scrollMode: pluginApi?.pluginSettings?.scrollMode ?? "always"

    property bool hovered: false

    // Explicit sizes for layout
    implicitWidth: widgetWidth
    implicitHeight: Style.capsuleHeight

    height: Style.capsuleHeight
    width: widgetWidth
    radius: Style.radiusM
    color: Style.capsuleColor
    clip: true

    border.width: Style.capsuleBorderWidth
    border.color: Style.capsuleBorderColor

    // Scrolling Logic
    Item {
        id: textContainer
        anchors.fill: parent
        anchors.margins: Style.marginS
        clip: true

        NText {
            id: label
            text: root.lyricText
            font.pixelSize: Style.fontSizeM
            color: root.hovered ? Color.mOnHover : Color.mOnSurface
            verticalAlignment: Text.AlignVCenter

            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }
            onTextChanged: {
                opacity = 0;
                opacity = 1;
                if (anim.running)
                    anim.restart();
            }

            NumberAnimation on x {
                id: anim
                from: 0
                to: -label.contentWidth + textContainer.width
                duration: Math.max(1000, (label.contentWidth / Math.max(1, root.scrollSpeed)) * 1000)
                running: {
                    if (label.contentWidth <= textContainer.width)
                        return false;
                    if (root.scrollMode === "none")
                        return false;
                    if (root.scrollMode === "hover" && !root.hovered)
                        return false;
                    return true;
                }
                loops: Animation.Infinite
                easing.type: Easing.Linear
            }

            onXChanged: {
                if (!anim.running)
                    x = 0;
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor

        onEntered: root.hovered = true
        onExited: root.hovered = false

        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) {
                contextMenu.openAt(mouse.x, mouse.y);
            }
        }
    }

    NPopupContextMenu {
        id: contextMenu
        itemHeight: 32
        implicitWidth: 160
        model: [
            {
                text: "Open Settings",
                icon: "settings",
                action: "settings"
            }
        ]
        onTriggered: action => {
            if (action === "settings") {
                settingsOverlay.visible = true;
            }
        }
    }

    // Settings Overlay Window
    PanelWindow {
        id: settingsOverlay

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        color: Color.transparent
        visible: false

        MouseArea {
            anchors.fill: parent
            onClicked: settingsOverlay.visible = false
        }

        Rectangle {
            width: 400
            height: 400
            anchors.centerIn: parent
            color: Color.mSurface
            radius: Style.radiusL
            border.color: Color.mOutline
            border.width: Style.borderS

            MouseArea {
                anchors.fill: parent
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginL
                spacing: Style.marginM

                NText {
                    text: "Lyrics Settings"
                    font.bold: true
                    font.pixelSize: Style.fontSizeL
                    Layout.alignment: Qt.AlignHCenter
                }

                Loader {
                    id: settingsLoader
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: "Settings.qml"
                    property var pluginApi: root.pluginApi
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: Style.marginS

                    // Fixed: Removed invalid 'type' property
                    NButton {
                        text: "Cancel"
                        onClicked: settingsOverlay.visible = false
                    }

                    NButton {
                        text: "Save"
                        // Calls apply() in Settings.qml to save the drafts
                        onClicked: {
                            if (settingsLoader.item) {
                                settingsLoader.item.apply();
                            }
                            settingsOverlay.visible = false;
                        }
                    }
                }
            }
        }
    }
}
