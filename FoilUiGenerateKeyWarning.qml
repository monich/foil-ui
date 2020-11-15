import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: dialog

    property var foilUi

    DialogHeader { id: header }

    Column {
        id: column

        spacing: Theme.paddingLarge
        anchors{
            top: header.bottom
            topMargin: Theme.paddingLarge
            left: parent.left
            right: parent.right
        }

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
}
