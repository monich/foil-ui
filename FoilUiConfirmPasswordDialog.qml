import QtQuick 2.0
import Sailfish.Silica 1.0

import "../harbour"

Dialog {
    id: thisPage

    forwardNavigation: false

    property var foilUi
    property string password
    property bool wrongPassword

    readonly property bool _landscapeLayout: isLandscape && Screen.sizeCategory < Screen.Large
    readonly property real _landscapeWidth: Screen.height - (('topCutout' in Screen) ? Screen.topCutout.height : 0)
    readonly property int _screenHeight: isPortrait ? Screen.height : Screen.width
    readonly property bool _canCheckPassword: inputField.text.length > 0 && !wrongPassword

    signal passwordConfirmed()

    function checkPassword() {
        if (inputField.text === password) {
            thisPage.passwordConfirmed()
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

    Item {
        id: iconContainer

        readonly property int _margins: Theme.horizontalPageMargin

        anchors {
            left: parent.left
            leftMargin: _landscapeLayout ? _margins : 0
        }

        HarbourHighlightIcon {
            id: icon


            readonly property int _size: Theme.itemSizeExtraLarge

            source: "images/password-confirm.svg"
            anchors.centerIn: parent
            sourceSize.width: _size
            width: _size
            opacity: ((iconContainer.x + x) > Theme.paddingLarge && (iconContainer.y + y) > Theme.paddingLarge) ? 1 : 0
            visible: opacity > 0

            Behavior on opacity { FadeAnimation { } }
        }

    }

    Item {
        id: inputContainer

        readonly property int _ymin: Theme.paddingLarge
        readonly property int _ymax1: _screenHeight/2 - inputField._backgroundRuleTopOffset - inputField.y
        readonly property int _ymax2: thisPage.height - inputField.height - inputField.y

        x: Theme.horizontalPageMargin + (_landscapeLayout ? (icon.width + 2 * iconContainer._margins) : 0)
        y: Math.min(_ymax1, _ymax2)
        width: parent.width - x - Theme.horizontalPageMargin
        height: inputPanel.height

        Column {
            id: inputPanel

            width: parent.width

            Column {
                width: parent.width
                spacing: Theme.paddingLarge

                InfoLabel {
                    readonly property int _y: inputContainer.y + y

                    text: foilUi.qsTrConfirmPasswordPrompt()
                    horizontalAlignment: Text.AlignLeft
                    // Hide it when it's only partially visible
                    opacity: (_y <= 0) ? 0 : 1
                    Behavior on opacity {
                        enabled: !orientationTransitionRunning
                        FadeAnimation { }
                    }
                }

                Label {
                    id: warning

                    x: Theme.horizontalPageMargin
                    width: parent.width - 2 * x
                    horizontalAlignment: Text.AlignLeft
                    text: foilUi.qsTrConfirmPasswordDescription()
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    wrapMode: Text.Wrap
                }

                HarbourPasswordInputField {
                    id: inputField

                    readonly property int _backgroundRuleTopOffset: contentItem.y + contentItem.height

                    width: parent.width
                    placeholderText: foilUi.qsTrConfirmPasswordRepeatPlaceholder()
                    label: foilUi.qsTrConfirmPasswordRepeatLabel()
                    onTextChanged: wrongPassword = false
                    EnterKey.enabled: _canCheckPassword
                    EnterKey.onClicked: checkPassword()
                }
            }

            Button {
                id: confirmButton

                anchors.rightMargin: Theme.horizontalPageMargin
                text: foilUi.qsTrConfirmPasswordButton()
                opacity: (inputContainer.y + inputContainer.height + Theme.paddingLarge < thisPage.height) ? 1 : 0
                enabled: _canCheckPassword && opacity > 0
                onClicked: checkPassword()
            }
        }
    }

    HarbourShakeAnimation  {
        id: wrongPasswordAnimation

        target: inputPanel
    }

    states: [
        State {
            name: "portrait"
            when: !_landscapeLayout
            changes: [
                AnchorChanges {
                    target: iconContainer
                    anchors {
                        top: parent.top
                        right: parent.right
                        bottom: inputContainer.top
                    }
                },
                AnchorChanges {
                    target: confirmButton
                    anchors {
                        right: undefined
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            ]
        },
        State {
            name: "landscape"
            when: _landscapeLayout
            changes: [
                AnchorChanges {
                    target: iconContainer
                    anchors {
                        top: inputContainer.top
                        right: inputContainer.left
                        bottom: inputContainer.bottom
                    }
                },
                AnchorChanges {
                    target: confirmButton
                    anchors {
                        right: parent.right
                        horizontalCenter: undefined
                    }
                }
            ]
        }
    ]
}
