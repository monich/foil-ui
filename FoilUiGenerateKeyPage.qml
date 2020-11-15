import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: thisPage

    property var foilModel
    property var foilUi
    property Page mainPage

    allowedOrientations: Orientation.All

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
