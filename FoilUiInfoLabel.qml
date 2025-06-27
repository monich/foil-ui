import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: thisItem

    property int maximumHeight: Theme.itemSizeHuge
    property alias shortText: shortTextLabel.text
    property alias longText: longTextLabel.text
    property alias horizontalAlignment: shortTextLabel.horizontalAlignment
    property alias verticalAlignment: shortTextLabel.verticalAlignment

    width: parent.width
    height: Math.min(maximumHeight, implicitHeight)
    implicitHeight: longTextLabel.implicitHeight <= maximumHeight ? longTextLabel.implicitHeight :
        shortTextLabel.implicitHeight <= maximumHeight ? shortTextLabel.implicitHeight :
        maximumHeight

    InfoLabel {
        id: shortTextLabel

        height: parent.height
        visible: opacity > 0
        opacity: 1 - longTextLabel.opacity
    }

    InfoLabel {
        id: longTextLabel

        height: parent.height
        horizontalAlignment: shortTextLabel.horizontalAlignment
        verticalAlignment: shortTextLabel.verticalAlignment
        visible: opacity > 0
        opacity: (height >= implicitHeight) ? 1 : 0

        Behavior on opacity { FadeAnimation { } }
    }
}
