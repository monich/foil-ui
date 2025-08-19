import QtQuick 2.0
import Sailfish.Silica 1.0

import "../harbour"

Page {
    id: thisPage

    allowedOrientations: Orientation.All

    property Page mainPage
    property var foilUi
    property var foilModel

    // Strings
    property alias promptText: prompt.text
    property alias currentPasswordLabel: currentPasswordField.label
    property alias newPasswordLabel: newPasswordField.label
    property alias buttonText: changePasswordButton.text

    property bool _wrongPassword
    readonly property var _settings: foilUi.settings
    readonly property real _landscapeWidth: Screen.height - (('topCutout' in Screen) ? Screen.topCutout.height : 0)
    readonly property bool _landscapeLayout: isLandscape && Screen.sizeCategory < Screen.Large
    readonly property int _screenHeight: isLandscape ? Screen.width : Screen.height
    readonly property bool _canChangePassword: currentPasswordField.text.length > 0 && newPasswordField.text.length > 0 &&
                            currentPasswordField.text !== newPasswordField.text && !_wrongPassword

    function invalidPassword() {
        _wrongPassword = true
        wrongPasswordAnimation.start()
        currentPasswordField.requestFocus()
    }

    function changePassword() {
        if (_canChangePassword) {
            if (foilModel.checkPassword(currentPasswordField.text)) {
                var dialog = pageStack.push(Qt.resolvedUrl("FoilUiConfirmPasswordDialog.qml"), {
                    allowedOrientations: thisPage.allowedOrientations,
                    foilUi: thisPage.foilUi,
                    password: newPasswordField.text
                })
                dialog.passwordConfirmed.connect(function() {
                    if (foilModel.changePassword(currentPasswordField.text, newPasswordField.text)) {
                        dialog.forwardNavigation = true
                        dialog.acceptDestinationAction = PageStackAction.Pop
                        dialog.acceptDestination = mainPage
                        dialog.accept()
                    } else {
                        invalidPassword()
                    }
                })
            } else {
                invalidPassword()
            }
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Activating) {
            currentPasswordField.requestFocus()
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
            topMargin: _landscapeLayout ? currentPasswordField.y : 0
            bottomMargin: _landscapeLayout ? changePasswordButton.height : 0
        }

        HarbourHighlightIcon {
            id: icon


            readonly property int _size: Theme.itemSizeExtraLarge

            source: "images/password-change.svg"
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
        readonly property int _ymax1: _screenHeight/2 - newPasswordField._backgroundRuleTopOffset - newPasswordField.y
        readonly property int _ymax2: thisPage.height - newPasswordField.height - newPasswordField.y

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
                    id: prompt

                    readonly property int _y: inputContainer.y + y

                    horizontalAlignment: Text.AlignLeft
                    // Hide it when it's only partially visible
                    opacity: _y <= 0 ? 0 : 1
                    Behavior on opacity {
                        enabled: !orientationTransitionRunning
                        FadeAnimation { }
                    }
                }

                HarbourPasswordInputField {
                    id: currentPasswordField

                    width: parent.width
                    onTextChanged: _wrongPassword = false
                    EnterKey.enabled: text.length > 0
                    EnterKey.onClicked: newPasswordField.focus = true
                }
            }

            HarbourPasswordInputField {
                id: newPasswordField

                readonly property int _backgroundRuleTopOffset: contentItem.y + contentItem.height

                width: parent.width
                EnterKey.enabled: _canChangePassword
                EnterKey.onClicked: changePassword()
            }

            Button {
                id: changePasswordButton

                anchors.rightMargin: Theme.horizontalPageMargin
                opacity: (inputContainer.y + inputContainer.height + Theme.paddingLarge < thisPage.height) ? 1 : 0
                enabled: _canChangePassword && opacity > 0
                onClicked: changePassword()
            }
        }
    }

    HarbourShakeAnimation  {
        id: wrongPasswordAnimation

        target: inputPanel
    }

    Loader {
        anchors {
            top: parent.top
            topMargin: _screenHeight - height - Theme.paddingLarge
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
        readonly property bool display: _settings.sharedKeyWarning2 && foilUi.otherFoilAppsInstalled
        opacity: display ? 1 : 0
        active: opacity > 0
        sourceComponent: Component {
            FoilUiAppsWarning {
                foilUi: thisPage.foilUi
                onClicked: _settings.sharedKeyWarning2 = false
            }
        }
        Behavior on opacity { FadeAnimation {} }
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
                    target: changePasswordButton
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
                    target: changePasswordButton
                    anchors {
                        right: parent.right
                        horizontalCenter: undefined
                    }
                }
            ]
        }
    ]
}
