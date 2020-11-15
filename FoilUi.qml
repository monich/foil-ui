import QtQuick 2.0

//
// Boilerplate object demostrating what FoilUi components expect from the
// object passed in as foilUi. This one is not supposed to be actually used,
// it's just an illustration. A real app has to allocate its own, providing
// proper translations, access to its own settings and so on.
//
// Access to strings is implemented as functions to avoid translating
// strings which are not actually being used.
//
// FoilUi components also take foilModel parameter which is expected to
// provide this property:
//
//   int foilState
//
// and these methods:
//
//   bool checkPassword(QString password)
//   bool changePassword(QString oldPassword, QString newPassword)
//   void generateKey(int bits, QString password)
//
QtObject {
    readonly property real opacityFaint: 0.2    // HarbourTheme.opacityFaint
    readonly property real opacityLow: 0.4      // HarbourTheme.opacityLow
    readonly property real opacityHigh: 0.6     // HarbourTheme.opacityHigh
    readonly property real opacityOverlay: 0.8  // HarbourTheme.opacityOverlay

    //
    // The settings object is expected to provide the following properties:
    //
    // bool sharedKeyWarning (for the password entry page)
    // bool sharedKeyWarning2 (for the password change page)
    //
    readonly property var settings: ({})

    readonly property bool otherFoilAppsInstalled: false

    // Model state checks (real app needs to actually check the model state)
    function isLockedState(foilState) { return false }
    function isReadyState(foilState) { return false }
    function isGeneratingKeyState(foilState) { return false }

    // FoilUiEnterPasswordView.qml
    function qsTrEnterPasswordViewMenuGenerateNewKey() {
        // Pulley menu item
        return "Generate a new key"
    }
    function qsTrEnterPasswordViewEnterPasswordLong() {
        // Password prompt label (long)
        return "Please enter your password to decrypt your stuff"
    }
    function qsTrEnterPasswordViewEnterPasswordShort() {
        // Password prompt label (short)
        return "Please enter your password"
    }
    function qsTrEnterPasswordViewButtonUnlock() {
        // Button label
        return "Unlock"
    }
    function qsTrEnterPasswordViewButtonUnlocking() {
        // Button label
        return "Unlocking..."
    }

    // FoilUiAppsWarning.qml
    function qsTrAppsWarningText() {
        // Warning text, small size label below the password prompt
        return "Note that all Foil apps share the encryption key and the password."
    }

    // FoilUiGenerateKeyWarning.qml
    function qsTrGenerateKeyWarningTitle() {
        // Title for the new key warning
        return "Warning"
    }
    function qsTrGenerateKeyWarningText() {
        // Warning shown prior to generating the new key
        return "Once you have generated a new key, you are going to lose access to all the files encrypted by the old key. Note that the same key is used by all Foil apps, such as Foil Auth and Foil Pics. If you have forgotten your password, then keep in mind that most likely it's computationally easier to brute-force your password and recover the old key than to decrypt files for which the key is lost."
    }

    // FoilUiGenerateKeyPage.qml
    function qsTrGenerateNewKeyPrompt() {
        // Prompt label
        return "You are about to generate a new key"
    }

    // FoilUiGenerateKeyView.qml
    function qsTrGenerateKeySizeLabel() {
        // Combo box label
        return "Key size"
    }
    function qsTrGenerateKeyPasswordDescription(minLen) {
        // Password field label
        return "Type at least %0 character(s)".arg(minLen)
    }
    function qsTrGenerateKeyButtonGenerate() {
        // Button label
        return "Generate key"
    }
    function qsTrGenerateKeyButtonGenerating() {
        // Button label
        return "Generating..."
    }

    // FoilUiConfirmPasswordDialog.qml
    function qsTrConfirmPasswordPrompt() {
        // Password confirmation label
        return "Please type in your new password one more time"
    }
    function qsTrConfirmPasswordDescription() {
        // Password confirmation description
        return "Make sure you don't forget your password. It's impossible to either recover it or to access the encrypted data without knowing it. Better take it seriously."
    }
    function qsTrConfirmPasswordRepeatPlaceholder() {
        // Placeholder for the password confirmation prompt
        return "New password again"
    }
    function qsTrConfirmPasswordRepeatLabel() {
        // Label for the password confirmation prompt
        return "New password"
    }
    function qsTrConfirmPasswordButton() {
        // Button label (confirm password)
        return "Confirm"
    }
}
