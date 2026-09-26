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

    component NumField: TextField {
        id: field

        required property real num
        property bool sci: false

        signal committed(real v) // note: only emitted for v > 0; range rules live in each handler

        function fmt(v) {
            return sci ? v.toExponential(3) : v.toFixed(0)
        }

        function resync() {
            text = Qt.binding(() => fmt(num)) // note: binding won't fire if num is unchanged, so reassign
        }

        horizontalAlignment: TextInput.AlignRight
        text: fmt(num)

        validator: DoubleValidator {
            bottom: 0 // note: no range here; a range blocks typing digits that start below it
            notation: field.sci ? DoubleValidator.ScientificNotation : DoubleValidator.StandardNotation
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
            sci: input.sci

            onCommitted: (v) => {
                input.setBounds(Math.min(input.from, v), Math.max(input.to, v)) // note: out-of-range values widen the bounds
                input.value = v
            }
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
            sci: input.sci
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
                input.value = Math.max(input.from, input.sci ? Number(v.toPrecision(4)) : Math.round(v)) // note: rounding could hit 0 when from < 1
            }
        }

        NumField {
            Layout.preferredWidth: 80
            num: input.to
            sci: input.sci
            onCommitted: (v) => input.setBounds(input.from, v)
        }
    }
}