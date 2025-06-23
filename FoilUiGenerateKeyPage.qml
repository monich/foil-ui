import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: thisPage

    allowedOrientations: Orientation.All

    property var foilModel
    property var foilUi
    property Page mainPage

    readonly property real _landscapeWidth: Screen.height - (('topCutout' in Screen) ? Screen.topCutout.height : 0)

    // Otherwise width is changing with a delay, causing visible layout changes
    // when on-screen keyboard is active and taking part of the screen.
    onIsLandscapeChanged: width = isLandscape ? _landscapeWidth : Screen.width

    Connections {
        target: foilModel
        onFoilStateChanged: {
            if (!foilUi.isReadyState(foilModel.foilState)) {
                thisPage.backNavigation = false
                pageStack.pop(pageStack.previousPage(thisPage))
            }
        }
    }

    FoilUiGenerateKeyView {
        anchors.fill: parent
        foilUi: thisPage.foilUi
        foilModel: thisPage.foilModel
        page: thisPage
        prompt: foilUi.qsTrGenerateNewKeyPrompt()
    }
}
