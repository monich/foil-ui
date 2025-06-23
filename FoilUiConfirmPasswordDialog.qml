import QtQuick 2.0
import Sailfish.Silica 1.0

import "../harbour"

Dialog {
    id: dialog

    forwardNavigation: false

    property var foilUi
    property string password
    property bool wrongPassword

    readonly property bool _landscapeLayout: isLandscape && Screen.sizeCategory < Screen.Large
    readonly property real _landscapeWidth: Screen.height - (('topCutout' in Screen) ? Screen.topCutout.height : 0)
    readonly property bool _canCheckPassword: inputField.text.length > 0 && !wrongPassword
    readonly property int _fullHeight: isPortrait ? Screen.height : Screen.width

    signal passwordConfirmed()

    function checkPassword() {
        if (inputField.text === password) {
            dialog.passwordConfirmed()
        } else {
            wrongPassword = true
            wrongPasswordAnimation.start()
            inputField.requestFocus()
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            inputField.requestFocus()
        }
    }

    // Otherwise width is changing with a delay, causing visible layout changes
    // when on-screen keyboard is active and taking part of the screen.
    onIsLandscapeChanged: width = isLandscape ? _landscapeWidth : Screen.width

    InfoLabel {
        text: foilUi.qsTrConfirmPasswordPrompt()

        // Bind to panel x position for shake animation
        x: Theme.horizontalPageMargin + panel.x
        width: parent.width - 2 * Theme.horizontalPageMargin
        anchors {
            bottom: panel.top
            bottomMargin: Theme.paddingLarge
        }

        // Hide it when it's only partially visible
        opacity: (y < Theme.paddingSmall) ? 0 : 1
        Behavior on opacity {
            enabled: !orientationTransitionRunning
            FadeAnimation { }
        }
    }

    Item {
        id: panel

        width: parent.width
        height: childrenRect.height + (_landscapeLayout ? 0 : Theme.paddingLarge)
        y: Math.min((_fullHeight - height)/2, parent.height - panel.height)

        Label {
            id: warning

            x: Theme.horizontalPageMargin
            width: parent.width - 2 * x
            text: foilUi.qsTrConfirmPasswordDescription()
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            wrapMode: Text.Wrap
        }

        HarbourPasswordInputField {
            id: inputField

            anchors {
                left: panel.left
                top: warning.bottom
                topMargin: Theme.paddingLarge
            }

            placeholderText: foilUi.qsTrConfirmPasswordRepeatPlaceholder()
            label: foilUi.qsTrConfirmPasswordRepeatLabel()
            onTextChanged: dialog.wrongPassword = false
            EnterKey.enabled: dialog._canCheckPassword
            EnterKey.onClicked: dialog.checkPassword()
        }

        Button {
            id: button

            anchors.bottomMargin: Theme.paddingLarge
            text: foilUi.qsTrConfirmPasswordButton()
            enabled: dialog._canCheckPassword
            onClicked: dialog.checkPassword()
        }
    }

    HarbourShakeAnimation  {
        id: wrongPasswordAnimation

        target: panel
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
