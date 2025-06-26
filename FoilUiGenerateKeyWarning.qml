import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    property var foilUi

    DialogHeader { id: header }

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

            Row {
                // Center the title
                x: Math.max(Math.floor((parent.width - title.width)/2 - title.x), 0)
                spacing: Theme.paddingLarge

                Image {
                    source: "images/warning.svg"
                    sourceSize.height: title.font.pixelSize
                    anchors.bottom: title.baseline
                }

                Label {
                    id: title

                    text: foilUi.qsTrGenerateKeyWarningTitle()
                    color: Theme.secondaryHighlightColor
                    font {
                        pixelSize: Theme.fontSizeExtraLarge
                        family: Theme.fontFamilyHeading
                        capitalization: Font.AllUppercase
                        bold: true
                    }
                }
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
