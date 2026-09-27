pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    readonly property real grav: 6.674e-11 // m³/(kg·s²)
    readonly property real orbit_radius: planet_input.value + altitude_input.value // km
    readonly property real orbit_m: orbit_radius * 1000
    readonly property real speed: Math.sqrt(grav * mass_input.value / orbit_m) // m/s; note: circular orbit, v = √(GM/r)
    readonly property real period: 2 * Math.PI * orbit_m / speed // s

    readonly property real day: 86400 // s
    readonly property real year: 365.25 * day // note: Julian year, as the IAU light-year uses
    readonly property real planck: 5.391247e-44 // s; CODATA 2018
    readonly property var time_units: [ // note: var lists become QML sequences, which lack .at()
        [year * 1000, "millennia"], [year * 100, "centuries"], [year * 10, "decades"], [year, "years"], // note: spelled out as decades etc. have no common abbreviation
        [day, "d"], [3600, "h"], [60, "min"], [1, "s"],
        [1e-3, "ms"], [1e-6, "μs"], [1e-9, "ns"], [1e-12, "ps"],
        [1e-15, "femtoseconds"], [1e-18, "attoseconds"], [1e-21, "zeptoseconds"], // note: spelled out past ps as they're unfamiliar
        [1e-24, "yoctoseconds"], [1e-27, "rontoseconds"],
        [1e-30, "quectoseconds", 2 * planck], // note: no SI prefix below quecto, so it spans down to Planck time
        [planck, "Planck times"]
    ]

    readonly property real c: 299792458 // m/s, i.e. 1 light-second per second
    readonly property var speed_units: [
        [c * year, "light-years per second"],
        [c * day, "light-days per second"], [c * 3600, "light-hours per second"],
        [c * 60, "light-minutes per second"], [c, "light-seconds per second"],
        [1000, "km/s"], [1, "m/s"], [0.01, "cm/s"], [0.001, "mm/s"]
    ]

    // note: widest possible stat, so the panel never clips; "8.8888e+308" is the widest number fmtNum can emit
    readonly property real stat_width: Math.ceil(stat_metrics.advanceWidth("8.8888e+308 ") + Math.max(...time_units.concat(speed_units).map(([, u]) => stat_metrics.advanceWidth(u))))

    function fmtNum(v, digits) {
        const fixed = v.toFixed(digits)
        const small = v !== 0 && Math.abs(v) < 0.1
        const large = Math.abs(Number(fixed)) >= 1e5 // note: test the rounded value so e.g. 99999.996 → "100000.00" still switches
        return small || large ? v.toExponential(4) : fixed // note: 5 sig figs once fixed notation would lose or bloat digits
    }

    function fmtTime(s) {
        const [n, u] = time_units.find(([n, , min = n * 2]) => s >= min) ?? time_units[time_units.length - 1] // note: ×2 so e.g. 90 min doesn't read as 1.5 h
        return fmtNum(s / n, 1) + " " + u
    }

    function fmtSpeed(ms) {
        const [n, u] = speed_units.find(([n]) => ms >= n) ?? speed_units[speed_units.length - 1] // note: no ×2 here so anything past c reads in light units and anything under 1 km/s in m/s
        return fmtNum(ms / n, 2) + " " + u
    }

    width: 1200
    height: 675
    minimumWidth: 800
    minimumHeight: 450
    visibility: Window.Maximized
    title: "Orbit Calculator"

    component Stat: ColumnLayout {
        property alias label: label_text.text
        property alias value: value_text.text

        spacing: 0

        Label {
            id: label_text
            color: palette.placeholderText
        }

        Label {
            id: value_text
            font.pixelSize: stat_metrics.font.pixelSize
        }
    }

    FontMetrics {
        id: stat_metrics
        font.family: root.font.family
        font.pixelSize: 24
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
                value: root.fmtSpeed(root.speed)
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