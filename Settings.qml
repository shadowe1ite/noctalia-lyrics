import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Widgets

ColumnLayout {
    id: root
    property var pluginApi: null

    // Load settings
    property int draftWidth: pluginApi?.pluginSettings?.widgetWidth ?? 215
    property int draftSpeed: pluginApi?.pluginSettings?.scrollSpeed ?? 70
    property string draftMode: pluginApi?.pluginSettings?.scrollMode ?? "always"
    property int draftFontSize: pluginApi?.pluginSettings?.fontSize ?? 9

    spacing: Style.marginM

    function saveSettings() {
        if (pluginApi) {
            pluginApi.pluginSettings.widgetWidth = draftWidth;
            pluginApi.pluginSettings.scrollSpeed = draftSpeed;
            pluginApi.pluginSettings.scrollMode = draftMode;

            // Only saving Font Size now
            pluginApi.pluginSettings.fontSize = draftFontSize;

            pluginApi.saveSettings();
        }
    }

    // --- Font Size ---
    NLabel {
        label: "Font Size"
        description: "Text size in points."
    }

    RowLayout {
        Layout.fillWidth: true
        NSlider {
            Layout.fillWidth: true
            from: 8
            to: 32
            value: draftFontSize
            onValueChanged: draftFontSize = value
        }
        NText {
            text: Math.round(draftFontSize) + "pt"
        }
    }

    NDivider {
        Layout.fillWidth: true
    }

    // --- Widget Width ---
    NLabel {
        label: "Widget Width"
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

    // --- Scroll Speed ---
    NLabel {
        label: "Scroll Speed"
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

    // --- Scroll Mode ---
    NComboBox {
        label: "Scroll Mode"
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
}
