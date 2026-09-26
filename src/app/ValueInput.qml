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

    function fmt(v) {
        return sci ? v.toExponential(3) : v.toFixed(0)
    }

    spacing: 4

    RowLayout {
        Layout.fillWidth: true

        Label {
            id: label_text
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        TextField {
            id: field
            Layout.preferredWidth: 96
            horizontalAlignment: TextInput.AlignRight
            text: input.fmt(input.value)
            validator: DoubleValidator {
                bottom: input.from
                top: input.to
                notation: input.sci ? DoubleValidator.ScientificNotation : DoubleValidator.StandardNotation
                locale: "C"
            }

            onEditingFinished: input.value = Number(text)
            onActiveFocusChanged: if (!activeFocus) text = Qt.binding(() => input.fmt(input.value)) // note: revert rejected text; binding won't fire if value is unchanged
        }

        Label {
            text: input.unit
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
            input.value = input.sci ? Number(v.toPrecision(4)) : Math.round(v)
        }
    }
}
