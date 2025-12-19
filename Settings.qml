import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    property var pluginApi: null

    // Local Draft Properties
    property int draftWidth: 300
    property int draftSpeed: 50
    property string draftMode: "always"

    spacing: Style.marginM

    // Load actual settings into drafts when loaded
    Component.onCompleted: {
        if (pluginApi) {
            draftWidth = pluginApi.pluginSettings.widgetWidth ?? 300;
            draftSpeed = pluginApi.pluginSettings.scrollSpeed ?? 50;
            draftMode = pluginApi.pluginSettings.scrollMode ?? "always";
        }
    }

    // External Apply Function
    // Called by the main Settings Window OR our custom overlay
    function apply() {
        if (pluginApi) {
            pluginApi.pluginSettings.widgetWidth = draftWidth;
            pluginApi.pluginSettings.scrollSpeed = draftSpeed;
            pluginApi.pluginSettings.scrollMode = draftMode;
            pluginApi.saveSettings();
        }
    }

    NLabel {
        label: "Widget Width"
        description: "Width of the lyrics bar widget in pixels."
    }

    RowLayout {
        Layout.fillWidth: true
        NSlider {
            Layout.fillWidth: true
            from: 100
            to: 500
            value: draftWidth
            onValueChanged: draftWidth = value
        }
        NText {
            text: Math.round(draftWidth) + "px"
        }
    }

    NLabel {
        label: "Scroll Speed"
        description: "Speed of the marquee animation (pixels/sec)."
    }

    RowLayout {
        Layout.fillWidth: true
        NSlider {
            Layout.fillWidth: true
            from: 10
            to: 200
            value: draftSpeed
            onValueChanged: draftSpeed = value
        }
        NText {
            text: Math.round(draftSpeed) + " px/s"
        }
    }

    NComboBox {
        label: "Scroll Mode"
        description: "When should the lyrics scroll?"
        Layout.fillWidth: true
        model: [
            {
                name: "Always Scroll",
                key: "always"
            },
            {
                name: "Scroll on Hover",
                key: "hover"
            },
            {
                name: "Don't Scroll",
                key: "none"
            }
        ]
        currentKey: draftMode
        onSelected: key => draftMode = key
    }

    Item {
        Layout.fillHeight: true
    } // Spacer
}
