import QtQuick 2.0
import Sailfish.Silica 1.0

import "../harbour"

Item {
    id: thisView

    property var foilUi
    property var foilModel
    property Page page
    property Component iconComponent

    property bool _completed
    property bool _wrongPassword
    readonly property var _settings: foilUi.settings
    readonly property bool _landscapeLayout: page.isLandscape && Screen.sizeCategory < Screen.Large
    readonly property int _screenHeight: page.isLandscape ? Screen.width : Screen.height
    readonly property bool _unlocking: !foilUi.isLockedState(foilModel.foilState)
    readonly property bool _canEnterPassword: inputField.text.length > 0 && !_unlocking &&
                                    !wrongPasswordAnimation.running && !_wrongPassword

    function enterPassword() {
        if (!foilModel.unlock(inputField.text)) {
            _wrongPassword = true
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
                foilUi: thisView.foilUi,
                allowedOrientations: page.allowedOrientations,
                acceptDestinationProperties: {
                    allowedOrientations: page.allowedOrientations,
                    mainPage: page,
                    foilUi: thisView.foilUi,
                    foilModel: foilModel
                },
                acceptDestinationAction: PageStackAction.Replace,
                acceptDestination: Qt.resolvedUrl("FoilUiGenerateKeyPage.qml")
            })
        }
    }

    Item {
        id: iconContainer

        readonly property int _margins: Theme.horizontalPageMargin
        readonly property int _y1: Math.round((loginLabel.y - height)/2) // portrait
        readonly property int _y2: Math.round((thisView.height - height)/2) // landscape
        readonly property int _y3: Math.round(inputField._yAbs + inputField.height - height) // landscape

        y: _landscapeLayout ? Math.min(_y2, _y3) : _y1
        height: iconLoader.height
        anchors {
            left: parent.left
            leftMargin: _landscapeLayout ? _margins : 0
        }

        Loader {
            id: iconLoader

            opacity: ((iconContainer.x + x) >= Theme.paddingSmall && (iconContainer.y + y) > Theme.paddingSmall) ? 1 : 0
            visible: opacity > 0
            sourceComponent: iconComponent
            anchors.centerIn: iconContainer
        }
    }

    FoilUiInfoLabel {
        id: loginLabel

        x: inputContainer.x
        width: inputContainer.width
        anchors {
            bottom: inputContainer.top
            bottomMargin: _landscapeLayout ? 0 : Theme.paddingLarge
        }
        shortText: foilUi.qsTrEnterPasswordViewEnterPasswordShort()
        longText: foilUi.qsTrEnterPasswordViewEnterPasswordLong()
        opacity: inputContainer.y >= inputContainer._ymin ? 1 : 0
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    Column {
        id: inputContainer

        readonly property int _ymin: Theme.paddingLarge
        readonly property int _ymax1: _screenHeight/2 - inputField._backgroundRuleTopOffset - inputField.y
        readonly property int _ymax2: thisView.height - inputField.height - inputField.y

        x: Theme.horizontalPageMargin + (_landscapeLayout ? (iconLoader.width + 2 * iconContainer._margins) : 0)
        y: Math.min(_ymax1, _ymax2)
        width: parent.width - x - Theme.horizontalPageMargin

        HarbourPasswordInputField {
            id: inputField

            readonly property int _backgroundRuleTopOffset: contentItem.y + contentItem.height
            readonly property real _yAbs: inputContainer.y + y

            enabled: !_unlocking
            onTextChanged: _wrongPassword = false
            EnterKey.onClicked: enterPassword()
            EnterKey.enabled: _canEnterPassword
        }

        Button {
            id: unlockButton

            anchors.rightMargin: Theme.horizontalPageMargin
            opacity: (inputContainer.y + inputContainer.height + Theme.paddingLarge < thisView.height) ? 1 : 0
            text: _unlocking ?
                foilUi.qsTrEnterPasswordViewButtonUnlocking() :
                foilUi.qsTrEnterPasswordViewButtonUnlock()
            enabled: _canEnterPassword && opacity > 0
            onClicked: enterPassword()
        }
    }

    HarbourShakeAnimation  {
        id: wrongPasswordAnimation

        target: thisView
    }

    Loader {
        readonly property bool _display: _settings.sharedKeyWarning && foilUi.otherFoilAppsInstalled

        anchors {
            top: parent.top
            topMargin: _screenHeight - height - Theme.paddingLarge
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
        opacity: _display ? 1 : 0
        active: opacity > 0
        sourceComponent: Component {
            FoilUiAppsWarning {
                foilUi: thisView.foilUi
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
                    target: iconContainer
                    anchors.right: parent.right
                },
                AnchorChanges {
                    target: loginLabel
                    anchors.top: undefined
                },
                AnchorChanges {
                    target: unlockButton
                    anchors {
                        right: undefined
                        horizontalCenter: parent.horizontalCenter
                    }
                },
                PropertyChanges {
                    target: loginLabel
                    maximumHeight: Math.max(Math.min(thisView.height, _screenHeight/2) - iconLoader.height - 2 * iconContainer._margins - inputContainer._ymin - inputField._backgroundRuleTopOffset, Theme.itemSizeMedium)
                }
            ]
        },
        State {
            name: "landscape"
            when: _landscapeLayout
            changes: [
                AnchorChanges {
                    target: iconContainer
                    anchors.right: inputContainer.left
                },
                AnchorChanges {
                    target: loginLabel
                    anchors.top: parent.top
                },
                AnchorChanges {
                    target: unlockButton
                    anchors {
                        right: parent.right
                        horizontalCenter: undefined
                    }
                },
                PropertyChanges {
                    target: loginLabel
                    maximumHeight: ((inputContainer._ymax1 < inputContainer._ymax2) ? (_screenHeight/2 - inputField._backgroundRuleTopOffset) :
                        (thisView.height - inputField.height)) - inputContainer._ymin
                }
            ]
        }
    ]
}
