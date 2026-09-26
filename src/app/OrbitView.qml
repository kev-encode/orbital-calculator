import QtQuick

Item {
    id: view

    // to-do: bind to real inputs
    property real planet_radius: 6371
    property real orbit_radius: 10000
    property real period: 8000

    // note: fit orbit to view; planet keeps true scale relative to it
    readonly property real px_per_km: Math.min(width, height) * 0.425 / orbit_radius

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
}
