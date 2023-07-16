import QtQuick 2.0
import Sailfish.Silica 1.0

import "../harbour"

Item {
    id: view

    property var foilModel
    property var foilUi
    property Page page
    property bool wrongPassword
    property Component iconComponent

    property bool _completed
    readonly property var _settings: foilUi.settings
    readonly property int _screenHeight: page.isLandscape ? Screen.width : Screen.height
    readonly property bool _landscapeLayout: page.isLandscape && Screen.sizeCategory < Screen.Large
    readonly property bool _unlocking: !foilUi.isLockedState(foilModel.foilState)
    readonly property bool _canEnterPassword: inputField.text.length > 0 && !_unlocking &&
                                    !wrongPasswordAnimation.running && !wrongPassword

    function enterPassword() {
        if (!foilModel.unlock(inputField.text)) {
            wrongPassword = true
            wrongPasswordAnimation.start()
            requestFocus()
        }
    }

    function requestFocus() {
        inputField.requestFocus()
    }

    Component.onCompleted: _completed = true

    Timer {
        id: pullDownMenuVisibleTimer

        interval: 400
        onTriggered: pullDownMenu.visible = true
    }

    PullDownMenu {
        id: pullDownMenu

        visible: false

        readonly property bool shouldBeVisible: _completed && !Qt.inputMethod.visible

        // Hide immediately, show with a delay
        onShouldBeVisibleChanged: {
            if (shouldBeVisible) {
                pullDownMenuVisibleTimer.restart()
            } else {
                pullDownMenuVisibleTimer.stop()
                visible = false
            }
        }

        MenuItem {
            text: foilUi.qsTrEnterPasswordViewMenuGenerateNewKey()
            onClicked: pageStack.push(Qt.resolvedUrl("FoilUiGenerateKeyWarning.qml"), {
                foilUi: view.foilUi,
                allowedOrientations: page.allowedOrientations,
                acceptDestinationProperties: {
                    allowedOrientations: page.allowedOrientations,
                    mainPage: page,
                    foilUi: view.foilUi,
                    foilModel: foilModel
                },
                acceptDestinationAction: PageStackAction.Replace,
                acceptDestination: Qt.resolvedUrl("FoilUiGenerateKeyPage.qml")
            })
        }
    }

    Loader {
        sourceComponent: iconComponent
        visible: opacity > 0 && !page.orientationTransitionRunning
        anchors.horizontalCenter: parent.horizontalCenter
        y: (panel.y > height) ? Math.floor((panel.y - height)/2) : (panel.y - height)

        // Hide it when it's only partially visible (i.e. in landscape)
        // or getting too close to the edge of the screen
        opacity: (y < Theme.paddingLarge) ? 0 : 1
    }

    Item {
        id: panel

        width: parent.width
        height: childrenRect.height + (_landscapeLayout ? 0 : Theme.paddingLarge)
        y: Math.min(Math.floor((_screenHeight - height)/2), parent.height - height)

        readonly property bool showLongPrompt: y >= Theme.paddingMedium

        InfoLabel {
            id: longPrompt

            visible: panel.showLongPrompt
            text: foilUi.qsTrEnterPasswordViewEnterPasswordLong()
        }

        InfoLabel {
            anchors.bottom: longPrompt.bottom
            visible: !panel.showLongPrompt
            text: foilUi.qsTrEnterPasswordViewEnterPasswordShort()
        }

        HarbourPasswordInputField {
            id: inputField

            anchors {
                left: panel.left
                top: longPrompt.bottom
                topMargin: Theme.paddingLarge
            }
            enabled: !_unlocking
            onTextChanged: view.wrongPassword = false
            EnterKey.onClicked: view.enterPassword()
            EnterKey.enabled: view._canEnterPassword
        }

        Button {
            id: button

            text: _unlocking ?
                foilUi.qsTrEnterPasswordViewButtonUnlocking() :
                foilUi.qsTrEnterPasswordViewButtonUnlock()
            enabled: view._canEnterPassword
            onClicked: view.enterPassword()
        }
    }

    HarbourShakeAnimation  {
        id: wrongPasswordAnimation

        target: panel
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
        readonly property bool display: _settings.sharedKeyWarning && foilUi.otherFoilAppsInstalled
        opacity: display ? 1 : 0
        active: opacity > 0
        sourceComponent: Component {
            FoilUiAppsWarning {
                foilUi: view.foilUi
                onClicked: _settings.sharedKeyWarning = false
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
                    anchors {
                        topMargin: 0
                        rightMargin: 0
                    }
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
                        top: longPrompt.bottom
                        right: panel.right
                        horizontalCenter: undefined
                    }
                },
                PropertyChanges {
                    target: button
                    anchors {
                        topMargin: Theme.paddingLarge
                        rightMargin: Theme.horizontalPageMargin
                    }
                }
            ]
        }
    ]
}
