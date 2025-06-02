// Hexagon.qml
import QtQuick
import QtQuick.Shapes

Item {
    id: hexagonRoot
    required property int hexRow
    required property int hexCol

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
                if (hexagonRoot.currentHexState === BoardModel.Player1)
                    return "#3498db";
                if (hexagonRoot.currentHexState === BoardModel.Player2)
                    return "#e74c3c";
                return "#cccccc";
            }

            startX: hexagonRoot.hexSize * Math.cos(Math.PI / 6)
            startY: hexagonRoot.hexSize * Math.sin(Math.PI / 6)

            // Loop through 6 sides
            PathLine {
                x: hexagonRoot.hexSize * Math.cos(Math.PI / 2)
                y: hexagonRoot.hexSize * Math.sin(Math.PI / 2)
            }
            PathLine {
                x: hexagonRoot.hexSize * Math.cos(5 * Math.PI / 6)
                y: hexagonRoot.hexSize * Math.sin(5 * Math.PI / 6)
            }
            PathLine {
                x: hexagonRoot.hexSize * Math.cos(7 * Math.PI / 6)
                y: hexagonRoot.hexSize * Math.sin(7 * Math.PI / 6)
            }
            PathLine {
                x: hexagonRoot.hexSize * Math.cos(3 * Math.PI / 2)
                y: hexagonRoot.hexSize * Math.sin(3 * Math.PI / 2)
            }
            PathLine {
                x: hexagonRoot.hexSize * Math.cos(11 * Math.PI / 6)
                y: hexagonRoot.hexSize * Math.sin(11 * Math.PI / 6)
            }
            PathLine {
                x: hexagonRoot.hexSize * Math.cos(Math.PI / 6)
                y: hexagonRoot.hexSize * Math.sin(Math.PI / 6)
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
