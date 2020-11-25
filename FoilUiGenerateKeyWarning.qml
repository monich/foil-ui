import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property var foilUi

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            width: parent.width

            DialogHeader { }

            InfoLabel {
                text: foilUi.qsTrGenerateKeyWarningTitle()
                font.bold: true
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                text: foilUi.qsTrGenerateKeyWarningText()
                wrapMode: Text.Wrap
                color: Theme.highlightColor
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }
        }
    }
}
