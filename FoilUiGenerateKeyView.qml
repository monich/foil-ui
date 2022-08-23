import QtQuick 2.0
import Sailfish.Silica 1.0

import "../harbour"

Item {
    id: thisView

    property var foilUi
    property var foilModel
    property Page page
    property alias prompt: promptLabel.text

    readonly property int _minPassphraseLen: 8
    readonly property bool _canGenerate: inputField.text.length >= _minPassphraseLen && !_generating
    readonly property bool _generating: foilUi.isGeneratingKeyState(foilModel.foilState)
    readonly property bool _landscapeLayout: page.isLandscape && Screen.sizeCategory < Screen.Large
    readonly property int _fullHeight: page.isPortrait ? Screen.height : Screen.width

    function generateKey() {
        if (_canGenerate) {
            var dialog = pageStack.push(Qt.resolvedUrl("FoilUiConfirmPasswordDialog.qml"), {
                foilUi: thisView.foilUi,
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
        sourceSize.width: Theme.itemSizeHuge
        anchors.horizontalCenter: parent.horizontalCenter
        property real attachToY: panel.y + (promptLabel.visible ? promptLabel.y : keySize.y)
        y: (attachToY > height) ? Math.floor((attachToY - height)/2) : (attachToY - height)
        visible: opacity > 0
        // Hide it when it's getting too close to the top if the view
        opacity: (y < Theme.paddingLarge) ? 0 : 1
        Behavior on opacity { FadeAnimation { } }
    }

    Item {
        id: panel

        width: parent.width
        height: childrenRect.height + (_landscapeLayout ? 0 : Theme.paddingLarge)
        y: Math.min((_fullHeight - height)/2, parent.height - panel.height)

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
            enabled: !_generating
            width: inputField.width
            anchors {
                top: promptLabel.bottom
                topMargin: Theme.paddingLarge
            }
            menu: ContextMenu {
                MenuItem { text: "1024" }
                MenuItem { text: "2048" }
                MenuItem { text: "4096" }
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
            label: text.length < _minPassphraseLen ?
                foilUi.qsTrGenerateKeyPasswordDescription(_minPassphraseLen) :
                placeholderText
            enabled: !_generating
            EnterKey.enabled: _canGenerate
            EnterKey.onClicked: generateKey()
        }

        Button {
            id: button

            anchors.bottomMargin: Theme.paddingLarge
            text: _generating ?
                foilUi.qsTrGenerateKeyButtonGenerating() :
                foilUi.qsTrGenerateKeyButtonGenerate()
            enabled: _canGenerate
            onClicked: generateKey()
        }
    }

    states: [
        State {
            name: "portrait"
            when: !_landscapeLayout
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
                        right: undefined
                        horizontalCenter: parent.horizontalCenter
                        bottom: undefined
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
            when: _landscapeLayout
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
                        top: undefined
                        right: panel.right
                        horizontalCenter: undefined
                        bottom: inputField.bottom
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
