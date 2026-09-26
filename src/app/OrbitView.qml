import QtQuick
import QtQuick.Controls

Item {
    id: view

    property real planet_radius: 6371
    property real orbit_radius: 10000
    property real period: 8000 // to-do: derive from orbit speed

    // note: log2 so each wheel notch / slider step feels equal at any zoom
    property real zoom_log: 0
    readonly property real zoom_min: -3
    readonly property real zoom_max: 5

    // note: hold scale while dragging so size changes are visible, refit on release
    property bool frozen: false
    property real fit_radius: orbit_radius

    Behavior on fit_radius {
        NumberAnimation {
            duration: 400
            easing.type: Easing.OutCubic
        }
    }

    onOrbit_radiusChanged: if (!frozen) fit_radius = orbit_radius
    onFrozenChanged: fit_radius = orbit_radius // note: assigning on freeze breaks initial binding so stops tracking
    readonly property real px_per_km: Math.min(width, height) * 0.425 / fit_radius * Math.pow(2, zoom_log) // note: fit orbit to view; planet keeps true scale relative

    function zoomBy(step) {
        zoom_log = Math.max(zoom_min, Math.min(zoom_max, zoom_log + step))
    }

    clip: true

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Rectangle {
        id: orbit
        anchors.centerIn: parent
        width: view.orbit_radius * view.px_per_km * 2
        height: width
        radius: width / 2
        color: "transparent"
        border.color: "#555555"
        border.width: 1
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.max(8, view.planet_radius * view.px_per_km * 2)
        height: width
        radius: width / 2
        color: "#3b7dd8"
    }

    Item {
        anchors.fill: orbit

        Rectangle {
            width: 10
            height: 10
            radius: 5
            color: "white"
            x: parent.width - width / 2
            y: parent.height / 2 - height / 2
        }

        RotationAnimation on rotation {
            from: 0
            to: -360
            duration: view.period
            loops: Animation.Infinite
        }
    }

    WheelHandler {
        onWheel: (event) => view.zoomBy(event.angleDelta.y / 120 * 0.25)
    }

    Item {
        id: scale_bar

        // note: snap to 1/2/5 × 10^n km so the label stays readable
        readonly property real km: {
            const raw = 120 / view.px_per_km
            const mag = Math.pow(10, Math.floor(Math.log10(raw)))
            const step = raw / mag
            return mag * (step < 2 ? 1 : step < 5 ? 2 : 5)
        }

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 16
        width: km * view.px_per_km
        height: 24

        Label {
            anchors.left: parent.left
            anchors.top: parent.top
            text: scale_bar.km.toLocaleString(Qt.locale(), "f", 0) + " km"
            color: "white"
        }

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 2
            color: "white"
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            width: 2
            height: 8
            color: "white"
        }

        Rectangle {
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            width: 2
            height: 8
            color: "white"
        }
    }

    Slider {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 16
        height: Math.min(parent.height - 32, 300)
        orientation: Qt.Vertical
        from: view.zoom_min
        to: view.zoom_max
        value: view.zoom_log
        onMoved: view.zoom_log = value
    }
}
