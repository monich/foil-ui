import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property var foilUi

    DialogHeader {
        id: header

        spacing: 0
    }

    SilicaFlickable {
        // Same space above and below the content
        contentHeight: column.height + 2 * column.y
        clip: true
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Column {
            id: column

            y: spacing
            width: parent.width
            spacing: Theme.paddingLarge

            InfoLabel {
                text: foilUi.qsTrGenerateKeyWarningTitle()
                font.bold: true
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: foilUi.qsTrGenerateKeyWarningText()
                wrapMode: Text.Wrap
                color: Theme.highlightColor
            }
        }

        VerticalScrollDecorator { }
    }
}
