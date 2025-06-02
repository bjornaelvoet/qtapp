// Hexagon.qml
import QtQuick

Item {
    id: hexRoot

    property int hexRow: 0
    property int hexCol: 0
    property int currentHexState: 0 // Will be bound to C++ boardModel.getHexState()

    // hexSize property is passed from C++ HexCoordConverter.hexRadius() via Main.qml
    property real hexSize: HexCoordConverter.hexRadius

    // Calculated dimensions for flat-top hex based on hexSize
    readonly property real hexWidth: hexSize * Math.sqrt(3) // sqrt(3) is 1.732
    readonly property real hexHeight: hexSize * 2

    width: hexWidth
    height: hexHeight

    // Hexagon shape using Path
    Path {
        id: hexShape
        //anchors.centerIn: parent // Center the path within this Item
        //fillColor: {
        //    if (currentHexState === BoardModel.Player1) return "#3498db" // Blue
        //    if (currentHexState === BoardModel.Player2) return "#e74c3c" // Red
        //    return "#cccccc" // Light gray for empty
        //}
        //strokeColor: "black"
        //strokeWidth: 2

        // Vertices for a flat-top hexagon centered at (0,0)
        // M_PI is Math.PI in QML
        PathLine {
            x: hexRoot.hexSize * Math.cos(Math.PI * (0 / 3.0) + Math.PI / 6.0)
            y: hexRoot.hexSize * Math.sin(Math.PI * (0 / 3.0) + Math.PI / 6.0)
        } // Angle adjusted to start at top-left vertex for flat top
        PathLine {
            x: hexRoot.hexSize * Math.cos(Math.PI * (1 / 3.0) + Math.PI / 6.0)
            y: hexRoot.hexSize * Math.sin(Math.PI * (1 / 3.0) + Math.PI / 6.0)
        }
        PathLine {
            x: hexRoot.hexSize * Math.cos(Math.PI * (2 / 3.0) + Math.PI / 6.0)
            y: hexRoot.hexSize * Math.sin(Math.PI * (2 / 3.0) + Math.PI / 6.0)
        }
        PathLine {
            x: hexRoot.hexSize * Math.cos(Math.PI * (3 / 3.0) + Math.PI / 6.0)
            y: hexRoot.hexSize * Math.sin(Math.PI * (3 / 3.0) + Math.PI / 6.0)
        }
        PathLine {
            x: hexRoot.hexSize * Math.cos(Math.PI * (4 / 3.0) + Math.PI / 6.0)
            y: hexRoot.hexSize * Math.sin(Math.PI * (4 / 3.0) + Math.PI / 6.0)
        }
        PathLine {
            x: hexRoot.hexSize * Math.cos(Math.PI * (5 / 3.0) + Math.PI / 6.0)
            y: hexRoot.hexSize * Math.sin(Math.PI * (5 / 3.0) + Math.PI / 6.0)
        }
        PathLine {
            x: hexRoot.hexSize * Math.cos(Math.PI * (6 / 3.0) + Math.PI / 6.0)
            y: hexRoot.hexSize * Math.sin(Math.PI * (6 / 3.0) + Math.PI / 6.0)
        } // Close the path
    }

    // Hover effect using States and Transitions
    states: [
        State {
            name: "hovered"
            when: mouseArea.containsMouse
            PropertyChanges {
                target: hexShape
                strokeColor: "#2ecc71"
                strokeWidth: 4
            } // Green border
        }
    ]
    transitions: [
        Transition {
            from: "*"
            to: "hovered"
            PropertyAnimation {
                properties: "strokeWidth,strokeColor"
                duration: 100
            }
        },
        Transition {
            from: "hovered"
            to: "*"
            PropertyAnimation {
                properties: "strokeWidth,strokeColor"
                duration: 100
            }
        }
    ]

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true // Enable hover events
    }
}
