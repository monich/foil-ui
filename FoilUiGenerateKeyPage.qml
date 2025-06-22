import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: thisPage

    property var foilModel
    property var foilUi
    property Page mainPage

    allowedOrientations: Orientation.All

    onIsLandscapeChanged: {
        // In the older versions of Silica, the width was changing with a
        // delay, causing visible and unpleasant layout changes. When support
        // for cutout was introduced, this hack started to break the landscape
        // layout (with cutout enabled, the width of the page in landscape is
        // smaller than the screen height) and at the same time, the unpleasant
        // rotation effects seems to have gone away.
        if (!('hasCutouts' in Screen)) {
            width = isLandscape ? Screen.height : Screen.width
        }
    }

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
