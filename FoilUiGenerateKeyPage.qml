import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: thisPage

    property var foilModel
    property var foilUi
    property Page mainPage

    allowedOrientations: Orientation.All

    // Otherwise width is changing with a delay, causing visible layout changes
    onIsLandscapeChanged: width = isLandscape ? Screen.height : Screen.width

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
