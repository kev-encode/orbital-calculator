pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic // note: Basic is the lightest style, fully palette-driven, and fixed at compile time
import QtQuick.Layouts

ApplicationWindow {
    id: root

    // note: mass in kg, mean radius in km; ordered outward from the Sun
    readonly property var bodies: [
        { name: "Sun",     mass: 1.989e30, radius: 695700, color: "#ffc02e", shade: 1.3 },
        { name: "Mercury", mass: 3.301e23, radius: 2439.7, color: "#9e9a95" },
        { name: "Venus",   mass: 4.867e24, radius: 6051.8, color: "#e6d3a3" },
        { name: "Earth",   mass: 5.972e24, radius: 6371,   color: "#3b7dd8" },
        { name: "Mars",    mass: 6.417e23, radius: 3389.5, color: "#c1440e" },
        { name: "Jupiter", mass: 1.898e27, radius: 69911,  color: "#c8905c" },
        { name: "Saturn",  mass: 5.683e26, radius: 58232,  color: "#d4b06a" },
        { name: "Uranus",  mass: 8.681e25, radius: 25362,  color: "#7fd4e0" },
        { name: "Neptune", mass: 1.024e26, radius: 24622,  color: "#2f4bbf" }
    ]

    property int picked: 3 // note: Earth is the default; index, as list models copy objects so === can't match them
    readonly property var body: bodies[picked]

    function pick(i) {
        picked = i
        mass_input.setValue(body.mass) // note: re-picking the current body restores its values
        radius_input.setValue(body.radius)
    }

    readonly property real grav: 6.674e-11 // note: in (m^3)/(kg * s^2)
    readonly property real orbit_radius: radius_input.value + altitude_input.value // note: in km
    readonly property real orbit_m: orbit_radius * 1000
    readonly property real speed: Math.sqrt(grav * mass_input.value / orbit_m) // note: in m/s; circular orbit, v = sqrt(GM/r)
    readonly property real period: 2 * Math.PI * orbit_m / speed               // note: in s

    readonly property real day: 86400           // note: in s
    readonly property real year: 365.25 * day   // note: Julian year, as the IAU light-year uses
    readonly property real planck: 5.391247e-44 // note: in s; CODATA 2018

    // note: var lists become QML sequences, which lack .at()
    readonly property var time_units: [
        // note: spelled out as decades etc. have no common abbreviation
        [year * 1000, "millennia"],
        [year * 100, "centuries"],
        [year * 10, "decades"],
        [year, "years"],
        [day, "d"],
        [3600, "h"],
        [60, "min"],
        [1, "s"],
        [1e-3, "ms"],
        [1e-6, "μs"],
        [1e-9, "ns"],
        [1e-12, "ps"],
        // note: spelled out past ps as they're unfamiliar
        [1e-15, "femtoseconds"],
        [1e-18, "attoseconds"],
        [1e-21, "zeptoseconds"],
        [1e-24, "yoctoseconds"],
        [1e-27, "rontoseconds"],
        [1e-30, "quectoseconds", 2 * planck],
        [planck, "Planck times"],
    ]

    readonly property real c: 299792458 // note: in m/s (e.g., 1 light-second per second)

    readonly property var speed_units: [
        [c * year, "light-years per second"],
        [c * day, "light-days per second"],
        [c * 3600, "light-hours per second"],
        [c * 60, "light-minutes per second"],
        [c, "light-seconds per second"],
        [1000, "km/s"],
        [1, "m/s"],
        [0.01, "cm/s"],
        [0.001, "mm/s"],
    ]

    // note: widest possible stat, so the panel never clips; "8.8888e+308" is the widest number fmtNum can emit
    readonly property real stat_width: Math.ceil(stat_metrics.advanceWidth("8.8888e+308 ") + Math.max(...time_units.concat(speed_units).map(([, u]) => stat_metrics.advanceWidth(u))))

    function fmtNum(v, digits) {
        const fixed = v.toFixed(digits)
        const small = v !== 0 && Math.abs(v) < 0.1
        const large = Math.abs(Number(fixed)) >= 1e5       // note: test the rounded value so e.g. 99999.996 → "100000.00" still switches
        return small || large ? v.toExponential(4) : fixed // note: 5 sig figs once fixed notation would lose or bloat digits
    }

    function fmtTime(s) {
        // note: ×2 so e.g. 90 min doesn't read as 1.5 h
        const [n, u] = time_units.find(([n, , min = n * 2]) => s >= min) ?? time_units[time_units.length - 1]
        return fmtNum(s / n, 1) + " " + u
    }

    function fmtSpeed(ms) {
        // note: no ×2 here so anything past c reads in light units and anything under 1 km/s in m/s
        const [n, u] = speed_units.find(([n]) => ms >= n) ?? speed_units[speed_units.length - 1]
        return fmtNum(ms / n, 2) + " " + u
    }

    width: 1200
    height: 675
    minimumWidth: 800
    minimumHeight: 450
    visibility: Window.Maximized
    title: "Orbit Calculator"

    // note: always dark, whatever the OS theme, to match the space view; sets every role the used controls read (incl. the fields' context menu), so none falls back to a light system color
    palette {
        window:          "#0e1116"
        windowText:      "#e6e9ef"
        base:            "#161a21"
        text:            "#e6e9ef"
        button:          "#1a1f27"
        light:           "#232833"
        midlight:        "#1d222b"
        mid:             "#2a303b"
        dark:            "#3a414e"
        accent:          "#5eb1ff"
        highlight:       "#5eb1ff"
        highlightedText: "#0b0e13"
        placeholderText: "#8a93a3"
    }

    component Caption: Label {
        font.pixelSize: 11
        font.weight: Font.DemiBold
        font.letterSpacing: 1.2
        font.capitalization: Font.AllUppercase
        color: palette.placeholderText
    }

    component Stat: ColumnLayout {
        property alias label: label_text.text
        property alias value: value_text.text
        spacing: 0

        Caption {
            id: label_text
        }

        Label {
            id: value_text
            font: stat_metrics.font // note: the exact font stat_width measures
        }
    }

    FontMetrics {
        id: stat_metrics
        font.family: root.font.family
        font.pixelSize: 24
        font.weight: Font.Medium
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.margins: 16
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            Layout.minimumWidth: root.stat_width
            Layout.maximumWidth: Math.max(400, root.stat_width)
            spacing: 10

            ValueInput {
                id: mass_input
                label: "Planet mass"
                unit: "kg"
                sci: true
                value: root.body.mass
                from: 1e20
                to: 1e31 // note: covers every preset, so picking one never widens the range
            }

            ValueInput {
                id: radius_input
                label: "Planet radius"
                value: root.body.radius
                from: 100
                to: 1e6
            }

            ValueInput {
                id: altitude_input
                label: "Satellite distance from ground"
                value: 3629
                from: 10
                to: 100000
            }

            Caption {
                Layout.topMargin: 4
                text: "Presets"
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: -8 // note: bleed rows into the panel margin so their text lines up with the inputs
                Layout.rightMargin: -8
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: root.bodies
                currentIndex: root.picked
                highlightMoveDuration: 200 // note: the selection glides between rows
                highlightMoveVelocity: -1  // note: duration only, so long jumps take as long as short ones
                ScrollBar.vertical: ScrollBar {}

                highlight: Rectangle {
                    radius: 8
                    color: Qt.alpha(root.palette.accent, 0.1)
                    border.color: Qt.alpha(root.palette.accent, 0.5)
                }

                delegate: Rectangle {
                    id: preset

                    required property var modelData
                    required property int index

                    width: ListView.view.width
                    implicitHeight: row.implicitHeight + 16
                    radius: 8
                    // note: translucent so the highlight beneath stays visible
                    color: hover.hovered ? Qt.rgba(1, 1, 1, 0.04) : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    HoverHandler {
                        id: hover
                        cursorShape: Qt.PointingHandCursor
                    }

                    TapHandler {
                        onTapped: root.pick(preset.index)
                    }

                    RowLayout {
                        id: row
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 12

                        Planet {
                            radius: 14
                            body: preset.modelData
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Label {
                                Layout.fillWidth: true
                                text: preset.modelData.name
                                font.weight: Font.Medium
                                elide: Text.ElideRight
                            }

                            Label {
                                Layout.fillWidth: true
                                // note: mass in the input's notation; radius unrounded, unlike its input
                                text: preset.modelData.mass.toExponential(3) + " kg · " + preset.modelData.radius + " km"
                                font.pixelSize: 11
                                color: root.palette.placeholderText
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: root.palette.mid
            }

            Stat {
                label: "Orbit speed"
                value: root.fmtSpeed(root.speed)
            }

            Stat {
                label: "Orbit period"
                value: root.fmtTime(root.period)
            }
        }

        Rectangle {
            Layout.fillHeight: true
            implicitWidth: 1
            color: root.palette.mid
        }

        OrbitView {
            planet_radius: radius_input.value
            body: root.body // note: design stays with the picked body even as inputs are edited
            orbit_radius: root.orbit_radius
            period: root.period
            frozen: radius_input.dragging || altitude_input.dragging
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 3
        }
    }
}