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

    component NumField: TextField {
        id: field

        required property real num
        property real lo: 0
        property real hi: Infinity
        property bool sci: false

        signal committed(real v)

        function fmt(v) {
            return sci ? v.toExponential(3) : v.toFixed(0)
        }

        horizontalAlignment: TextInput.AlignRight
        text: fmt(num)

        validator: DoubleValidator {
            bottom: field.lo
            top: field.hi
            notation: field.sci ? DoubleValidator.ScientificNotation : DoubleValidator.StandardNotation
            locale: "C"
        }

        onEditingFinished: {
            committed(Number(text))
            text = Qt.binding(() => fmt(num)) // note: resync in case the commit was rejected or clamped
        }

        onActiveFocusChanged: if (!activeFocus) text = Qt.binding(() => fmt(num)) // note: revert rejected text; binding won't fire if num is unchanged
    }

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
            lo: input.from
            hi: input.to
            sci: input.sci
            onCommitted: (v) => input.value = v
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
            hi: input.to
            sci: input.sci
            onCommitted: (v) => {
                if (v <= 0 || v >= input.to) return // note: log slider needs 0 < from < to
                input.from = v
                input.value = Math.max(input.value, v)
            }
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
            lo: input.from
            sci: input.sci
            
            onCommitted: (v) => {
                if (v <= input.from) return
                input.to = v
                input.value = Math.min(input.value, v)
            }
        }
    }
}
