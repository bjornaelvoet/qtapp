// Main.qml
import QtQuick
import QtQuick.Controls // For controls like buttons, labels (if needed later)
import QtQuick.Layouts

// Importing our custom QML module
import QtAppQml

ApplicationWindow {

    // Expose the QML component to other QML components or C++
    id: appWindow
    visible: true
    width: 1000 // Adjust window size as needed
    height: 800
    title: "Hex Strategy Game (QML)"
    color: "#303030" // Dark background for contrast

    // Main game area
    Item {
        id: gameArea
        anchors.fill: parent
        anchors.margins: 20 // Some margin around the board
        // Center the game area visually
        anchors.centerIn: parent

        // QML Repeater to draw the grid of hexagons
        // The model comes from our C++ BoardModel's hexPositions() method
        Repeater {
            id: hexGridRepeater
            model: BoardModel // C++ BoardModel derives from QAbstractListModel

            // Each delegate represents one hexagon
            delegate: Hexagon {
                id: hexagon

                // Get the state of this hex from the C++ BoardModel
                // We use a property alias that reacts to boardModel.hexStateChanged signal
                property int currentHexState: BoardModel.getHexState(hexRow, hexCol)

                // Update hex color when state changes (C++ signal connects to this)
                // This connection ensures the QML Hexagon updates when BoardModel emits hexStateChanged
                Connections {
                    target: BoardModel as QtObject
                    function onHexStateChanged(r, c, newState) {
                        if (r === hexagon.hexRow && c === hexagon.hexCol) {
                            hexagon.currentHexState = newState;
                        }
                    }
                }

                // Calculate the position based on the C++ HexCoordConverter
                // This ensures consistent pixel coordinates
                x: HexCoordConverter.hexToPixel(hexRow, hexCol).x
                y: HexCoordConverter.hexToPixel(hexRow, hexCol).y

                // When this Hexagon is clicked, call the C++ makeMove method
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        BoardModel.makeMove(hexagon.hexRow, hexagon.hexCol);
                    }
                }

                // Add a simple animation on state change (e.g., scale up briefly)
                SequentialAnimation on currentHexState {
                    // Only animate if the state changes from Empty to something else
                    // or if you want to visually confirm any change
                    //running: hexagon.currentHexState !== BoardModel.Empty
                    running: hexagon.currentHexState !== BoardModel.Empty

                    // Animate a brief pulse on the hex when its state changes
                    ParallelAnimation {
                        NumberAnimation {
                            target: hexagon.parent
                            property: "scale"
                            from: 1.0
                            to: 1.1
                            duration: 100
                            easing.type: Easing.OutCubic
                        }
                        //NumberAnimation { target: parent; property: "scale"; from: 1.1; to: 1.0; duration: 200; easing.type: Easing.InCubic; delay: 100 }
                        NumberAnimation {
                            target: hexagon.parent
                            property: "scale"
                            from: 1.1
                            to: 1.0
                            duration: 200
                            easing.type: Easing.InCubic
                        }
                    }
                }

                // Placeholder for UnitItem (will be added later for movement)
                // You might add UnitItem as a child here or in a separate Repeater layer
                // UnitItem {
                //     id: unitOnHex
                //     // Properties like unitId, unitOwner, etc.
                //     anchors.centerIn: parent
                // }
            }
        } // End Repeater (for hexagons)

        // Adjust the position of the entire gameArea to center the board
        // This calculates the bounding box of the hexes and shifts them.
        // This is a bit complex as Repeater items aren't immediately available for bounds calculation.
        // A simpler way is to calculate board dimensions in C++ and set them here.
        // For now, let's just make sure the individual hexes are drawn.
    }

    // Overlay for game controls and info (e.g., current player, reset button)
    // Using simple Rectangles and Text for now, can be replaced by QtQuick.Controls.
    Rectangle {
        id: infoPanel
        width: parent.width * 0.25
        height: parent.height
        anchors.right: parent.right
        color: "#404040"
        border.color: "#505050"
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10

            Label {
                id: currentPlayerLabel
                text: "Current Player: " + (BoardModel.currentPlayer === 1 ? "Blue" : "Red")
                font.pointSize: 18
                color: "white"
                Layout.alignment: Qt.AlignHCenter
            }

            Label {
                id: gameOverLabel
                text: BoardModel.gameOver ? (BoardModel.currentPlayer === 1 ? "Red Wins!" : "Blue Wins!") : ""
                font.pointSize: 24
                color: BoardModel.gameOver ? "gold" : "transparent"
                Layout.alignment: Qt.AlignHCenter
            }

            Button {
                text: "Reset Game"
                onClicked: BoardModel.resetGame()
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 20
            }
        }
    }
}
