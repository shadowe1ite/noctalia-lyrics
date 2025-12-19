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

    property int widgetWidth: pluginApi?.pluginSettings?.widgetWidth ?? 300
    property int scrollSpeed: pluginApi?.pluginSettings?.scrollSpeed ?? 50
    property string scrollMode: pluginApi?.pluginSettings?.scrollMode ?? "always"

    property bool hovered: false

    implicitWidth: widgetWidth
    implicitHeight: Style.capsuleHeight

    height: Style.capsuleHeight
    width: widgetWidth
    radius: Style.radiusM
    color: Style.capsuleColor
    clip: true

    border.width: Style.capsuleBorderWidth
    border.color: Style.capsuleBorderColor

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
        onEntered: root.hovered = true
        onExited: root.hovered = false
    }
}
