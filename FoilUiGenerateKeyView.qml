import QtQuick 2.0
import Sailfish.Silica 1.0

import "../harbour"

Item {
    id: view

    property var foilUi
    property var foilModel
    property Page page
    property alias prompt: promptLabel.text

    readonly property int minPassphraseLen: 8
    readonly property bool canGenerate: inputField.text.length >= minPassphraseLen && !generating
    readonly property bool generating: foilUi.isGeneratingKeyState(foilModel.foilState)
    readonly property bool landscapeLayout: page.isLandscape && Screen.sizeCategory < Screen.Large

    function generateKey() {
        if (canGenerate) {
            var dialog = pageStack.push(Qt.resolvedUrl("FoilUiConfirmPasswordDialog.qml"), {
                foilUi: view.foilUi,
                allowedOrientations: page.allowedOrientations,
                password: inputField.text
            })
            dialog.passwordConfirmed.connect(function() {
                dialog.backNavigation = false
                foilModel.generateKey(keySize.value, inputField.text)
                dialog.forwardNavigation = true
                dialog.accept()
            })
        }
    }

    HarbourHighlightIcon {
        source: "images/key.svg"
        width: Theme.itemSizeHuge
        sourceSize.width: width
        anchors.horizontalCenter: parent.horizontalCenter
        property real attachToY: panel.y + keySize.y
        y: (attachToY > height) ? Math.floor((attachToY - height)/2) : (attachToY - height)
        visible: opacity > 0
        // Hide it when it's getting too close to the top if the view
        // Otherwise show it when the prompt is hidden
        opacity: (y < Theme.paddingLarge) ? 0 : (1 - promptLabel.opacity)
    }

    Item {
        id: panel

        width: parent.width
        height: childrenRect.height
        y: (parent.height > height) ? Math.floor((parent.height - height)/2) : (parent.height - height)

        InfoLabel {
            id: promptLabel

            height: implicitHeight
            visible: opacity > 0
            opacity: (parent.y >= Theme.paddingLarge) ? 1 : 0
            Behavior on opacity { FadeAnimation { } }
        }

        ComboBox {
            id: keySize

            label: foilUi.qsTrGenerateKeySizeLabel()
            enabled: !generating
            width: parent.width
            anchors {
                top: promptLabel.bottom
                topMargin: Theme.paddingLarge
            }
            menu: ContextMenu {
                MenuItem { text: "1024" }
                MenuItem { text: "1500" }
                MenuItem { text: "2048" }
            }
            Component.onCompleted: currentIndex = 2 // default
        }

        HarbourPasswordInputField {
            id: inputField

            anchors {
                left: parent.left
                top: keySize.bottom
                topMargin: Theme.paddingLarge
            }
            label: text.length < minPassphraseLen ?
                foilUi.qsTrGenerateKeyPasswordDescription(minPassphraseLen) :
                placeholderText
            enabled: !generating
            EnterKey.enabled: canGenerate
            EnterKey.onClicked: generateKey()
        }

        Button {
            id: button

            anchors.topMargin: Theme.paddingLarge
            text: generating ?
                foilUi.qsTrGenerateKeyButtonGenerating() :
                foilUi.qsTrGenerateKeyButtonGenerate()
            enabled: canGenerate
            onClicked: generateKey()
        }

        // Theme.paddingLarge pixels below the button in portrait
        Item {
            height: landscapeLayout ? 0 : Theme.paddingLarge
            anchors {
                top: button.bottom
                left: button.left
                right: button.right
            }
        }
    }

    states: [
        State {
            name: "portrait"
            when: !landscapeLayout
            changes: [
                AnchorChanges {
                    target: inputField
                    anchors.right: panel.right
                },
                PropertyChanges {
                    target: inputField
                    anchors.rightMargin: 0
                },
                AnchorChanges {
                    target: button
                    anchors {
                        top: inputField.bottom
                        horizontalCenter: parent.horizontalCenter
                    }
                },
                PropertyChanges {
                    target: button
                    anchors.rightMargin: 0
                }
            ]
        },
        State {
            name: "landscape"
            when: landscapeLayout
            changes: [
                AnchorChanges {
                    target: inputField
                    anchors.right: button.left
                },
                PropertyChanges {
                    target: inputField
                    anchors.rightMargin: Theme.horizontalPageMargin
                },
                AnchorChanges {
                    target: button
                    anchors {
                        top: keySize.bottom
                        right: panel.right
                        horizontalCenter: undefined
                    }
                },
                PropertyChanges {
                    target: button
                    anchors.rightMargin: Theme.horizontalPageMargin
                }
            ]
        }
    ]
}
