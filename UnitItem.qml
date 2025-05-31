// UnitItem.qml (Create this file, but you don't need to use it in Main.qml yet)
import QtQuick

Image {
    id: unitRoot
    property int unitId: -1
    property int unitOwner: 0 // 0: None, 1: Player1, 2: Player2
    property int currentHexRow: 0
    property int currentHexCol: 0 // Current logical position

    // Example source. You'll need to add images to your Qt resources.
    source: {
        if (unitOwner === 1) return "qrc:/images/blue_unit.png"
        if (unitOwner === 2) return "qrc:/images/red_unit.png"
        return "" // No image if no owner
    }
    width: 40 // Adjust size as needed
    height: 40
    smooth: true // For better image scaling

    // Place the unit at the center of its hex
    // You'd calculate this based on HexCoordConverter and the hex's pixel position
    // For now, these are just placeholders; animation logic will go here.
    x: coordConverter.hexToPixel(currentHexRow, currentHexCol).x - width/2
    y: coordConverter.hexToPixel(currentHexRow, currentHexCol).y - height/2
}