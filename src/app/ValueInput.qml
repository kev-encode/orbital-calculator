pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

ColumnLayout {
    id: input

    property alias label: label_text.text
    property string unit: "km"
    property real value
    property real from
    property real to
    property bool sci: false // note: for values too long to type in full, e.g. mass
    readonly property bool dragging: slider.pressed

    function setBounds(lo, hi) {
        if (lo >= hi) return
        from = lo
        to = hi
        value = Math.min(Math.max(value, lo), hi)
    }

    function setValue(v) {
        setBounds(Math.min(from, v), Math.max(to, v)) // note: out-of-range values widen the bounds
        value = v
    }

    function fmt(v) {
        if (sci) return v.toExponential(3)
        return v >= 100 ? v.toFixed(0) : String(Number(v.toPrecision(3))) // note: 3 sig figs below 100 so typed fractions like 0.4 don't read as 0
    }

    component NumField: TextField {
        id: field

        required property real num
        property color idle: palette.base // note: resting fill; hover and focus lift it

        signal committed(real v) // note: only emitted for v > 0; range rules live in input.setBounds and input.setValue

        function resync() {
            text = Qt.binding(() => input.fmt(num)) // note: binding won't fire if num is unchanged, so reassign
        }

        text: input.fmt(num)
        horizontalAlignment: TextInput.AlignRight
        padding: 4
        leftPadding: 8
        rightPadding: 8

        validator: DoubleValidator {
            bottom: 0 // note: no range here; a range blocks typing digits that start below it
            notation: input.sci ? DoubleValidator.ScientificNotation : DoubleValidator.StandardNotation
            locale: "C"
        }

        background: Rectangle {
            radius: 6
            color: field.activeFocus || field.hovered ? field.palette.button : field.idle
            border.color: field.activeFocus ? field.palette.accent : "transparent"

            Behavior on color {
                ColorAnimation { duration: 120 }
            }
        }

        onEditingFinished: {
            const v = Number(text)
            if (v > 0) committed(v) // note: log slider needs values > 0
            resync()                // note: in case the commit was rejected or clamped
        }

        onActiveFocusChanged: if (!activeFocus) resync() // note: revert text the validator never let finish
    }

    component Bound: NumField {
        Layout.preferredWidth: 96
        idle: "transparent" // note: bounds are secondary, so they only show as fields on hover
        topPadding: 2
        bottomPadding: 2
        leftPadding: 4 // note: matches the slider's padding, so text lines up with the track ends
        rightPadding: 4
        font.pixelSize: 11
        color: palette.placeholderText
    }

    Layout.fillWidth: true
    spacing: 0

    RowLayout {
        Layout.fillWidth: true
        spacing: 4

        Label {
            id: label_text
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        NumField {
            Layout.preferredWidth: 104
            num: input.value
            onCommitted: (v) => input.setValue(v)
        }

        Label {
            Layout.preferredWidth: 20 // note: fixed so fields line up whatever the unit
            text: input.unit
            color: palette.placeholderText
        }
    }

    // note: log scale so small and large values are both reachable
    SlimSlider {
        id: slider
        Layout.fillWidth: true
        from: Math.log10(input.from)
        to: Math.log10(input.to)
        value: Math.log10(input.value)

        onMoved: {
            // note: round to what the field shows, so dragged and typed values agree; rounding can leave the range
            const v = Number(input.fmt(Math.pow(10, value)))
            input.value = Math.min(input.to, Math.max(input.from, v))
        }
    }

    // note: bounds sit under the track ends like an axis
    RowLayout {
        Layout.fillWidth: true

        Bound {
            horizontalAlignment: TextInput.AlignLeft
            num: input.from
            onCommitted: (v) => input.setBounds(v, input.to)
        }

        Item {
            Layout.fillWidth: true
        }

        Bound {
            num: input.to
            onCommitted: (v) => input.setBounds(input.from, v)
        }
    }
}