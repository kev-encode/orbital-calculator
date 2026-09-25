import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root
    readonly property real scale: Math.min(width / 1200, height / 675)

    width: 1200
    height: 675
    minimumWidth: 800
    minimumHeight: 450
    visible: true
    visibility: Window.Maximized
    title: "Orbit Calculator"

    // to-do: replace each `Placeholder` with its real element
    component Placeholder: Rectangle {
        property alias label: label_text.text

        color: "transparent"
        border.color: root.palette.mid
        border.width: 1
        radius: 4

        Label {
            id: label_text
            anchors.centerIn: parent
            color: root.palette.placeholderText
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.maximumWidth: 400
            spacing: 8

            Placeholder {
                label: "Planet mass"
                Layout.fillWidth: true
                Layout.preferredHeight: 64
            }

            Placeholder {
                label: "Planet radius"
                Layout.fillWidth: true
                Layout.preferredHeight: 64
            }

            Placeholder {
                label: "Satellite distance from ground"
                Layout.fillWidth: true
                Layout.preferredHeight: 64
            }

            Item { Layout.fillHeight: true }

            Placeholder {
                label: "Orbit speed"
                Layout.fillWidth: true
                Layout.preferredHeight: 96
            }
        }

        Placeholder {
            label: "Orbit visualization"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 3
        }
    }
}