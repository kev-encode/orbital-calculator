import QtQuick
import QtQuick.Controls
import QtQuick.Shapes

Item {
    id: view

    required property real planet_radius
    required property real orbit_radius
    required property real period
    readonly property real time_scale: 1800 // note: 1 s on screen = 30 min of orbit
    readonly property real spin: 360 * time_scale / period // note: deg/s; uncapped, the trail covers aliasing on fast orbits
    readonly property real sweep: Math.min(360, spin * frame.smoothFrameTime) // note: deg moved per frame, drawn as a trail; smoothed so it doesn't flicker with frame jitter

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

    // note: fit orbit to view; planet keeps true scale relative
    readonly property real px_per_km: Math.min(width, height) * 0.425 / fit_radius * Math.pow(2, zoom_log)

    function zoomBy(step) {
        zoom_log = Math.max(zoom_min, Math.min(zoom_max, zoom_log + step))
    }

    component Circle: Rectangle {
        width: radius * 2 // note: callers set radius; Rectangle's corner radius doubles as the circle's
        height: width
    }

    component Bar: Rectangle {
        anchors.bottom: parent.bottom
        width: 2
        height: 8
        color: "white"
    }

    clip: true

    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Circle {
        id: orbit
        anchors.centerIn: parent
        radius: view.orbit_radius * view.px_per_km
        color: "transparent"
        border.color: "#555555"
        border.width: 1

        // note: motion blur over the arc swept each frame; a full ring once it passes 1 rev/frame
        Shape {
            anchors.fill: parent
            visible: view.sweep * Math.PI / 180 * orbit.radius > satellite.width // note: skip per-frame geometry rebuilds while the trail hides under the dot
            preferredRendererType: Shape.CurveRenderer
            opacity: 0.5

            ShapePath {
                strokeColor: "white"
                strokeWidth: satellite.width
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                PathAngleArc {
                    centerX: orbit.radius
                    centerY: orbit.radius
                    radiusX: orbit.radius
                    radiusY: orbit.radius
                    sweepAngle: view.sweep // note: positive is clockwise, i.e. behind the counter-clockwise satellite
                }
            }
        }

        Circle {
            id: satellite
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.verticalCenter
            radius: 5
            color: "white"
        }
    }

    Circle {
        anchors.centerIn: parent
        radius: Math.max(4, view.planet_radius * view.px_per_km)
        color: "#3b7dd8"
    }

    FrameAnimation {
        id: frame
        running: true
        onTriggered: {
            const step = (view.spin * frameTime) % 360 // note: % first keeps huge steps precise
            if (isFinite(step)) orbit.rotation = (orbit.rotation - step) % 360 // note: spinning the ring carries the satellite; skip ∞ spin (period 0) as NaN would stick forever
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
            text: scale_bar.km.toLocaleString(Qt.locale(), "f", 0) + " km"
            color: "white"
        }

        Bar {
            width: parent.width
            height: 2
        }

        Bar {}

        Bar {
            anchors.right: parent.right
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