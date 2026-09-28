import QtQuick
import QtQuick.Controls.Basic

Slider {
    id: control

    padding: 4

    handle: Rectangle {
        x: control.leftPadding + (control.horizontal ? control.visualPosition * (control.availableWidth - width) : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : control.visualPosition * (control.availableHeight - height))
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: control.palette.windowText
        border.width: control.visualFocus ? 2 : 0
        border.color: control.palette.accent
        scale: control.pressed ? 1.3 : control.hovered ? 1.15 : 1

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }
    }

    background: Rectangle {
        x: control.leftPadding + (control.horizontal ? 0 : (control.availableWidth - width) / 2)
        y: control.topPadding + (control.horizontal ? (control.availableHeight - height) / 2 : 0)
        implicitWidth: control.horizontal ? 160 : 4
        implicitHeight: control.horizontal ? 4 : 160
        width: control.horizontal ? control.availableWidth : implicitWidth
        height: control.horizontal ? implicitHeight : control.availableHeight
        radius: 2
        color: control.palette.mid

        // note: vertical fills up from the bottom
        Rectangle {
            y: control.horizontal ? 0 : control.visualPosition * parent.height
            width: control.horizontal ? control.position * parent.width : parent.width
            height: control.horizontal ? parent.height : control.position * parent.height
            radius: 2
            color: control.palette.accent
        }
    }
}