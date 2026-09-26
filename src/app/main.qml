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
        spacing: 0

        ColumnLayout {
            Layout.margins: 16
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

            ValueInput {
                id: planet_input
                label: "Planet radius"
                value: 6371
                from: 100
                to: 100000
                Layout.fillWidth: true
            }

            ValueInput {
                id: altitude_input
                label: "Satellite distance from ground"
                value: 3629
                from: 10
                to: 100000
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            }

            Placeholder {
                label: "Orbit speed"
                Layout.fillWidth: true
                Layout.preferredHeight: 96
            }
        }

        OrbitView {
            planet_radius: planet_input.value
            orbit_radius: planet_input.value + altitude_input.value
            frozen: planet_input.dragging || altitude_input.dragging
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 3
        }
    }
}