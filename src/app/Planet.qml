import QtQuick
import QtQuick.Shapes

Shape {
    id: planet

    required property var body
    property real radius
    readonly property real rim: radius * 1.15 // note: paths center on the rim, as Shape sizes itself to them; keeps the body centered

    preferredRendererType: Shape.CurveRenderer // note: resolution-independent antialiasing, so edges stay crisp at any zoom

    // note: soft atmosphere rim, drawn first so the body covers its inner part
    ShapePath {
        strokeColor: "transparent"

        fillGradient: RadialGradient {
            centerX: planet.rim
            centerY: planet.rim
            centerRadius: planet.rim
            focalX: centerX
            focalY: centerY
            // note: fade in the same hue, not to transparent black
            GradientStop { position: 0.8; color: Qt.alpha(planet.body.color, 0.45) }
            GradientStop { position: 1;   color: Qt.alpha(planet.body.color, 0) }
        }

        PathAngleArc {
            centerX: planet.rim
            centerY: planet.rim
            radiusX: planet.rim
            radiusY: planet.rim
            sweepAngle: 360
        }
    }

    // note: off-center radial gradient reads as a sphere lit from the top-left
    ShapePath {
        strokeColor: "transparent"

        fillGradient: RadialGradient {
            centerX: planet.rim - planet.radius * 0.3
            centerY: planet.rim - planet.radius * 0.4
            centerRadius: planet.radius * 1.6
            focalX: centerX
            focalY: centerY
            // note: optional shade, so self-lit bodies like the Sun barely darken
            GradientStop { position: 0; color: Qt.lighter(planet.body.color, 1.3) }
            GradientStop { position: 1; color: Qt.darker(planet.body.color, planet.body.shade ?? 2.5) }
        }

        PathAngleArc {
            centerX: planet.rim
            centerY: planet.rim
            radiusX: planet.radius
            radiusY: planet.radius
            sweepAngle: 360
        }
    }
}