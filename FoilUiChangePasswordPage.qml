import QtQuick 2.0
import Sailfish.Silica 1.0

import "../harbour"

Page {
    id: page

    allowedOrientations: Orientation.All

    property Page mainPage
    property var foilUi
    property var foilModel
    property bool wrongPassword
    property alias currentPassword: currentPasswordField.text
    property alias newPassword: newPasswordField.text

    // Strings
    property alias promptText: prompt.text
    property alias currentPasswordLabel: currentPasswordField.label
    property alias newPasswordLabel: newPasswordField.label
    property alias buttonText: changePasswordButton.text

    readonly property var _settings: foilUi.settings
    readonly property bool _landscapeLayout: isLandscape && Screen.sizeCategory < Screen.Large
    readonly property real _fullHeight: isPortrait ? Screen.height : Screen.width
    readonly property bool _canChangePassword: currentPassword.length > 0 && newPassword.length > 0 &&
                            currentPassword !== newPassword && !wrongPassword

    function invalidPassword() {
        wrongPassword = true
        wrongPasswordAnimation.start()
        currentPasswordField.requestFocus()
    }

    function changePassword() {
        if (_canChangePassword) {
            if (foilModel.checkPassword(currentPassword)) {
                var dialog = pageStack.push(Qt.resolvedUrl("FoilUiConfirmPasswordDialog.qml"), {
                    allowedOrientations: page.allowedOrientations,
                    foilUi: page.foilUi,
                    password: newPassword
                })
                dialog.passwordConfirmed.connect(function() {
                    if (foilModel.changePassword(currentPassword, newPassword)) {
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

    InfoLabel {
        id: prompt

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
        height: childrenRect.height
        y: (parent.height > height) ? Math.floor((parent.height - height)/2) : (parent.height - height)

        HarbourPasswordInputField {
            id: currentPasswordField

            anchors.left: panel.left
            onTextChanged: page.wrongPassword = false

            EnterKey.enabled: text.length > 0
            EnterKey.onClicked: newPasswordField.focus = true
        }

        HarbourPasswordInputField {
            id: newPasswordField

            anchors {
                left: currentPasswordField.left
                right: currentPasswordField.right
                top: currentPasswordField.bottom
            }

            EnterKey.enabled: page._canChangePassword
            EnterKey.onClicked: page.changePassword()
        }

        Button {
            id: changePasswordButton

            anchors {
                topMargin: Theme.paddingLarge
                bottomMargin: 2 * Theme.paddingSmall
            }

            enabled: page._canChangePassword
            onClicked: page.changePassword()
        }
    }

    HarbourShakeAnimation  {
        id: wrongPasswordAnimation

        target: panel
    }

    Loader {
        anchors {
            top: parent.top
            topMargin: _fullHeight - height - Theme.paddingLarge
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
                foilUi: page.foilUi
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
                    target: currentPasswordField
                    anchors.right: panel.right
                },
                PropertyChanges {
                    target: currentPasswordField
                    anchors {
                        rightMargin: 0
                        bottomMargin: Theme.paddingLarge
                    }
                },
                AnchorChanges {
                    target: changePasswordButton
                    anchors {
                        top: newPasswordField.bottom
                        right: undefined
                        horizontalCenter: parent.horizontalCenter
                        bottom: undefined
                    }
                },
                PropertyChanges {
                    target: changePasswordButton
                    anchors.rightMargin: 0
                }
            ]
        },
        State {
            name: "landscape"
            when: _landscapeLayout
            changes: [
                AnchorChanges {
                    target: currentPasswordField
                    anchors.right: changePasswordButton.left
                },
                PropertyChanges {
                    target: currentPasswordField
                    anchors {
                        rightMargin: Theme.horizontalPageMargin
                        bottomMargin: Theme.paddingSmall
                    }
                },
                AnchorChanges {
                    target: changePasswordButton
                    anchors {
                        top: undefined
                        right: panel.right
                        horizontalCenter: undefined
                        bottom: newPasswordField.bottom
                    }
                },
                PropertyChanges {
                    target: changePasswordButton
                    anchors.rightMargin: Theme.horizontalPageMargin
                }
            ]
        }
    ]
}
