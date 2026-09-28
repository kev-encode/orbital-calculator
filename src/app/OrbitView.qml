pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import QtQuick.Shapes

Rectangle {
    id: view

    required property real planet_radius
    required property var body // note: design only; size comes from planet_radius
    required property real orbit_radius
    required property real period
    readonly property real time_scale: 1800                // note: 1 s on screen = 30 min of orbit
    readonly property real spin: 360 * time_scale / period // note: deg/s; uncapped, the blur covers aliasing on fast orbits
    readonly property real trail: Math.min(360, spin)      // note: deg covered in the last second on screen, so faster orbits leave longer trails

    // note: deg moved per frame, drawn as motion blur; smoothed so it doesn't flicker with frame jitter
    readonly property real sweep: Math.min(360, spin * frame.smoothFrameTime)

    // note: log2 so each wheel notch / slider step feels equal at any zoom
    property real zoom_target: 0 // note: input writes here; zoom_log eases toward it
    property real zoom_log: zoom_target
    readonly property real zoom_min: -3
    readonly property real zoom_max: 5

    Behavior on zoom_log {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic // note: restarts from the current value, so rapid notches chain without jumps
        }
    }

    // note: hold scale while dragging so size changes are visible, refit on release
    property bool frozen: false
    property real fit_radius: orbit_radius

    // note: eased copies of the radii, so picks and typed values glide instead of jumping then refitting; live while dragging
    property real shown_planet: planet_radius
    property real shown_orbit: orbit_radius

    Behavior on fit_radius { Ease {} }
    Behavior on shown_planet { enabled: !view.frozen; Ease {} }
    Behavior on shown_orbit { enabled: !view.frozen; Ease {} }

    onOrbit_radiusChanged: if (!frozen) fit_radius = orbit_radius
    onFrozenChanged: fit_radius = orbit_radius // note: assigning on freeze breaks initial binding so stops tracking

    // note: fit orbit to view; planet keeps true scale relative
    readonly property real px_per_km: Math.min(width, height) * 0.425 / fit_radius * Math.pow(2, zoom_log)

    function zoomBy(step) {
        // note: step off the target, not the animated value, so fast scrolls accumulate
        zoom_target = Math.max(zoom_min, Math.min(zoom_max, zoom_target + step))
    }

    component Ease: NumberAnimation {
        duration: 400
        easing.type: Easing.OutCubic
    }

    component Bar: Rectangle {
        anchors.bottom: parent.bottom
        width: 1
        height: 6
        color: palette.windowText
    }

    component Zoom: Label {
        id: zoom

        required property real step

        Layout.alignment: Qt.AlignHCenter
        font.pixelSize: 16
        color: hover.hovered ? palette.windowText : palette.placeholderText

        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            gesturePolicy: TapHandler.WithinBounds // note: grabs the press, so quick repeat taps don't also reach the view's double-tap reset
            onTapped: view.zoomBy(zoom.step)
        }
    }

    color: "#05070b"
    clip: true

    // note: painted once per resize; stars sit at fixed pixels in repeating tiles, so resizing reveals rather than reshuffles them
    Canvas {
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.fillStyle = "white"

            for (let ox = 0; ox < width; ox += 1024) {
                for (let oy = 0; oy < height; oy += 1024) {
                    let seed = 1
                    const rand = () => (seed = seed * 16807 % 2147483647) / 2147483647 // note: seeded (Park-Miller), so every repaint draws the same sky

                    for (let i = 0; i < 180; i++) {
                        const size = 0.6 + rand() * rand() * 1.6 // note: product skews toward small, faint stars
                        ctx.globalAlpha = 0.15 + rand() * 0.55
                        ctx.fillRect(ox + rand() * 1024, oy + rand() * 1024, size, size)
                    }
                }
            }
        }
    }

    Planet {
        anchors.centerIn: parent
        radius: Math.max(4, view.shown_planet * view.px_per_km)
        body: view.body
    }

    Item {
        id: orbit

        readonly property real radius: view.shown_orbit * view.px_per_km

        anchors.centerIn: parent
        width: radius * 2
        height: width

        // note: spinning the ring carries the trail too, so its geometry only rebuilds when the orbit changes
        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: Qt.rgba(1, 1, 1, 0.12)
                fillColor: "transparent"

                PathAngleArc {
                    centerX: orbit.radius
                    centerY: orbit.radius
                    radiusX: orbit.radius
                    radiusY: orbit.radius
                    sweepAngle: 360
                }
            }

            // note: a band behind the satellite, filled rather than stroked as only fills take gradients
            ShapePath {
                strokeColor: "transparent"

                fillGradient: ConicalGradient {
                    centerX: orbit.radius
                    centerY: orbit.radius
                    // note: runs counter-clockwise from the satellite, so 1 is just behind it
                    GradientStop { position: 1 - view.trail / 360; color: Qt.alpha(view.palette.accent, 0) }
                    GradientStop { position: 1; color: view.palette.accent }
                }

                PathAngleArc {
                    centerX: orbit.radius
                    centerY: orbit.radius
                    radiusX: orbit.radius + 1.5
                    radiusY: orbit.radius + 1.5
                    sweepAngle: view.trail
                }

                PathAngleArc {
                    centerX: orbit.radius
                    centerY: orbit.radius
                    radiusX: orbit.radius - 1.5
                    radiusY: orbit.radius - 1.5
                    startAngle: view.trail
                    sweepAngle: -view.trail
                    moveToStart: false // note: joins the outer arc's end, closing the band
                }
            }
        }

        // note: motion blur over the arc swept each frame; a full ring once it passes 1 rev/frame
        Shape {
            anchors.fill: parent
            visible: view.sweep * Math.PI / 180 * orbit.radius > satellite.dot * 2 // note: skip per-frame geometry rebuilds while the blur hides under the dot
            preferredRendererType: Shape.CurveRenderer
            opacity: 0.5

            ShapePath {
                strokeColor: "white"
                strokeWidth: satellite.dot * 2
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

        Shape {
            id: satellite

            readonly property real dot: 4 // note: in px
            readonly property real glow: 16

            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.verticalCenter
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                strokeColor: "transparent"

                fillGradient: RadialGradient {
                    centerX: satellite.glow
                    centerY: satellite.glow
                    centerRadius: satellite.glow
                    focalX: centerX
                    focalY: centerY
                    GradientStop { position: 0; color: Qt.alpha(view.palette.accent, 0.6) }
                    GradientStop { position: 1; color: Qt.alpha(view.palette.accent, 0) }
                }

                PathAngleArc {
                    centerX: satellite.glow
                    centerY: satellite.glow
                    radiusX: satellite.glow
                    radiusY: satellite.glow
                    sweepAngle: 360
                }
            }

            ShapePath {
                strokeColor: "transparent"
                fillColor: "white"

                PathAngleArc {
                    centerX: satellite.glow
                    centerY: satellite.glow
                    radiusX: satellite.dot
                    radiusY: satellite.dot
                    sweepAngle: 360
                }
            }
        }
    }

    FrameAnimation {
        id: frame
        running: true
        onTriggered: {
            const step = (view.spin * frameTime) % 360 // note: % first keeps huge steps precise
            // note: spinning the ring carries the satellite; skip ∞ spin (period 0) as NaN would stick forever
            if (isFinite(step)) orbit.rotation = (orbit.rotation - step) % 360
        }
    }

    WheelHandler {
        onWheel: (event) => view.zoomBy(event.angleDelta.y / 120 * 0.25)
    }

    TapHandler {
        onDoubleTapped: view.zoom_target = 0
    }

    Item {
        id: scale_bar

        // note: snap to 1/2/5 × 10^n km so the label stays readable
        readonly property real mag: Math.pow(10, Math.floor(Math.log10(120 / view.px_per_km)))
        readonly property real km: {
            const step = 120 / view.px_per_km / mag
            return mag * (step < 2 ? 1 : step < 5 ? 2 : 5)
        }

        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 20
        width: km * view.px_per_km
        height: 22
        opacity: 0.8 // note: bright text, dimmed as a whole, so it reads over both space and a zoomed-in planet

        Label {
            // note: decimals below 1 km, else it reads 0
            text: scale_bar.km.toLocaleString(Qt.locale(), "f", Math.max(0, -Math.round(Math.log10(scale_bar.mag)))) + " km"
            font.pixelSize: 11
        }

        Bar {
            width: parent.width
            height: 1
        }

        Bar {}

        Bar {
            anchors.right: parent.right
        }
    }

    ColumnLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 12
        height: Math.min(parent.height - 40, 300)
        spacing: 0

        Zoom {
            text: "+"
            step: 1
        }

        SlimSlider {
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            orientation: Qt.Vertical
            from: view.zoom_min
            to: view.zoom_max
            value: view.zoom_target // note: bind to target so the handle doesn't fight the easing mid-drag
            onMoved: view.zoom_target = value
        }

        Zoom {
            text: "−"
            step: -1
        }
    }
}