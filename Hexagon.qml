// Hexagon.qml
import QtQuick
import QtQuick.Shapes

Item {
    id: hexRoot
    property int hexRow: 0
    property int hexCol: 0
    property int currentHexState: 0
    property real hexSize: HexCoordConverter.hexRadius

    readonly property real hexWidth: hexSize * Math.sqrt(3)
    readonly property real hexHeight: hexSize * 2

    width: hexWidth
    height: hexHeight

    Shape {
        anchors.centerIn: parent

        ShapePath {
            strokeColor: mouseArea.containsMouse ? "#2ecc71" : "black"
            strokeWidth: mouseArea.containsMouse ? 4 : 2
            fillColor: {
                if (hexRoot.currentHexState === BoardModel.Player1)
                    return "#3498db";
                if (hexRoot.currentHexState === BoardModel.Player2)
                    return "#e74c3c";
                return "#cccccc";
            }

            startX: hexSize * Math.cos(Math.PI / 6)
            startY: hexSize * Math.sin(Math.PI / 6)

            // Loop through 6 sides
            PathLine {
                x: hexSize * Math.cos(Math.PI / 2)
                y: hexSize * Math.sin(Math.PI / 2)
            }
            PathLine {
                x: hexSize * Math.cos(5 * Math.PI / 6)
                y: hexSize * Math.sin(5 * Math.PI / 6)
            }
            PathLine {
                x: hexSize * Math.cos(7 * Math.PI / 6)
                y: hexSize * Math.sin(7 * Math.PI / 6)
            }
            PathLine {
                x: hexSize * Math.cos(3 * Math.PI / 2)
                y: hexSize * Math.sin(3 * Math.PI / 2)
            }
            PathLine {
                x: hexSize * Math.cos(11 * Math.PI / 6)
                y: hexSize * Math.sin(11 * Math.PI / 6)
            }
            PathLine {
                x: hexSize * Math.cos(Math.PI / 6)
                y: hexSize * Math.sin(Math.PI / 6)
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
