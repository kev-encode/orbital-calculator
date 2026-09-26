import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    readonly property real grav: 6.674e-11 // m³/(kg·s²)
    readonly property real orbit_radius: planet_input.value + altitude_input.value // km
    readonly property real speed: Math.sqrt(grav * mass_input.value / (orbit_radius * 1000)) // m/s; note: circular orbit, v = √(GM/r)
    readonly property real period: 2 * Math.PI * orbit_radius * 1000 / speed // s

    function fmtTime(s) {
        const units = [[86400, "d"], [3600, "h"], [60, "min"], [1, "s"]]
        const [n, u] = units.find(([n]) => s >= n * 2) ?? units[3] // note: ×2 so e.g. 90 min doesn't read as 1.5 h
        return (s / n).toFixed(1) + " " + u
    }

    width: 1200
    height: 675
    minimumWidth: 800
    minimumHeight: 450
    visible: true
    visibility: Window.Maximized
    title: "Orbit Calculator"

    component Stat: ColumnLayout {
        property alias label: label_text.text
        property alias value: value_text.text

        Layout.fillWidth: true
        spacing: 0

        Label {
            id: label_text
            color: palette.placeholderText
        }

        Label {
            id: value_text
            font.pixelSize: 24
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

            ValueInput {
                id: mass_input
                label: "Planet mass"
                unit: "kg"
                sci: true
                value: 5.972e24
                from: 1e20
                to: 1e28
            }

            ValueInput {
                id: planet_input
                label: "Planet radius"
                value: 6371
                from: 100
                to: 100000
            }

            ValueInput {
                id: altitude_input
                label: "Satellite distance from ground"
                value: 3629
                from: 10
                to: 100000
            }

            Item {
                Layout.fillHeight: true
            }

            Stat {
                label: "Orbit speed"
                value: (root.speed / 1000).toFixed(2) + " km/s"
            }

            Stat {
                label: "Orbit period"
                value: root.fmtTime(root.period)
            }
        }

        OrbitView {
            planet_radius: planet_input.value
            orbit_radius: root.orbit_radius
            period: root.period
            frozen: planet_input.dragging || altitude_input.dragging
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 3
        }
    }
}
