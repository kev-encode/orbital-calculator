pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
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

    component NumField: TextField {
        required property real num

        signal committed(real v) // note: only emitted for v > 0; range rules live in input.setBounds and input.setValue

        function fmt(v) {
            if (input.sci) return v.toExponential(3)
            return v >= 100 ? v.toFixed(0) : String(Number(v.toPrecision(3))) // note: 3 sig figs below 100 so typed fractions like 0.4 don't read as 0
        }

        function resync() {
            text = Qt.binding(() => fmt(num)) // note: binding won't fire if num is unchanged, so reassign
        }

        horizontalAlignment: TextInput.AlignRight
        text: fmt(num)

        validator: DoubleValidator {
            bottom: 0 // note: no range here; a range blocks typing digits that start below it
            notation: input.sci ? DoubleValidator.ScientificNotation : DoubleValidator.StandardNotation
            locale: "C"
        }

        onEditingFinished: {
            const v = Number(text)
            if (v > 0) committed(v) // note: log slider needs values > 0
            resync() // note: in case the commit was rejected or clamped
        }

        onActiveFocusChanged: if (!activeFocus) resync() // note: revert text the validator never let finish
    }

    Layout.fillWidth: true
    spacing: 4

    RowLayout {
        Layout.fillWidth: true

        Label {
            id: label_text
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        NumField {
            Layout.preferredWidth: 96
            num: input.value
            onCommitted: (v) => input.setValue(v)
        }

        Label {
            text: input.unit
        }
    }

    RowLayout {
        Layout.fillWidth: true

        NumField {
            Layout.preferredWidth: 80
            num: input.from
            onCommitted: (v) => input.setBounds(v, input.to)
        }

        // note: log scale so small and large values are both reachable
        Slider {
            id: slider
            Layout.fillWidth: true
            from: Math.log10(input.from)
            to: Math.log10(input.to)
            value: Math.log10(input.value)

            onMoved: {
                const v = Math.pow(10, value)
                // note: rounding can leave the range, e.g. hit 0 when from < 1
                input.value = Math.min(input.to, Math.max(input.from, input.sci ? Number(v.toPrecision(4)) : Math.round(v)))
            }
        }

        NumField {
            Layout.preferredWidth: 80
            num: input.to
            onCommitted: (v) => input.setBounds(input.from, v)
        }
    }
}