import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: warning

    property var foilUi

    height: Theme.itemSizeSmall
    opacity: foilUi.opacityHigh


    signal clicked()

    Timer {
        running: true
        repeat: true
        interval: 2000
        onTriggered: icons.incrementCurrentIndex()
    }

    SlideshowView {
        id: icons

        width: Math.floor(Theme.itemSizeSmall/2)
        height: width
        anchors.verticalCenter: parent.verticalCenter
        clip: true

        readonly property size size: Qt.size(width, height)

        model: [ "foilpics.svg", "foilauth.svg", "foilnotes.svg" ]

        delegate: Image {
            source: "images/" + modelData
            sourceSize: icons.size
        }
    }

    MouseArea {
        anchors {
            top: parent.top
            bottom: parent.bottom
            leftMargin: Theme.paddingLarge
            left: icons.right
            right: parent.right
        }

        readonly property bool down: pressed && containsMouse
        readonly property bool showPress: down || pressTimer.running

        onClicked: warning.clicked()

        onPressedChanged: {
            if (pressed) {
                pressTimer.start()
            }
        }

        onCanceled: pressTimer.stop()

        Timer {
            id: pressTimer

            interval: 64
        }

        Label {
            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter
            }
            font.pixelSize: Theme.fontSizeExtraSmall
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignLeft
            color: Theme.highlightColor
            opacity: parent.showPress ? foilUi.opacityHigh : 1
            text: foilUi.qsTrAppsWarningText()
        }
    }
}
