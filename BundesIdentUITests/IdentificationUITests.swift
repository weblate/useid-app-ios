import XCTest

// swiftlint:disable type_body_length
final class IdentificationUITests: XCTestCase {
    func testIdentificationTriggersSetupForFirstTimeUsers() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithResetUserDefaults()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.staticTexts[L10n.FirstTimeUser.Intro.title].assertExistence()
    }
    
    func testIdentificationShowAttributeDetails() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.moreInfo].wait().tap()
        
        app.staticTexts[L10n.Identification.AttributeConsentInfo.terms].assertExistence()
        app.navigationBars.buttons.firstMatch.wait().tap()
    }
    
    func testIdentificationHappyPath() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        
        app.buttons[L10n.Identification.Scan.scan].wait().tap()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["identifySuccessfully"].wait().tap()
        
        app.buttons[L10n.Home.startSetup].assertExistence()
        
        let safari = XCUIApplication(bundleIdentifier: SafariIdentifiers.bundleId.rawValue)
        XCTAssertEqual(safari.state, .runningForeground)
    }
    
    func testIdentificationHappyPathSkippingInstructions() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launchWithIdentifiedOnce()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["identifySuccessfully"].wait().tap()
        
        app.buttons[L10n.Home.startSetup].assertExistence()
        
        let safari = XCUIApplication(bundleIdentifier: SafariIdentifiers.bundleId.rawValue)
        XCTAssertEqual(safari.state, .runningForeground)
    }
    
    func testIdentificationOverviewBackToSetupIntro() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.buttons[L10n.FirstTimeUser.Intro.skipSetup].wait().tap()
        
        app.navigationBars.buttons[L10n.General.back].wait().tap()
        
        app.staticTexts[L10n.FirstTimeUser.Intro.title].assertExistence()
    }
    
    func testIdentificationLoadError() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["loadError"].wait().tap()
        
        app.buttons[L10n.Identification.FetchMetadataError.retry].wait().tap()
        
        app.staticTexts[L10n.Identification.FetchMetadata.pleaseWait].assertExistence()
    }
    
    func testIdentificationScanHelp() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        
        app.buttons[L10n.Scan.helpScanning].wait().tap()
        
        app.staticTexts[L10n.ScanError.CardUnreadable.title].assertExistence()
        app.buttons[L10n.ScanError.close].wait().tap()
        
        app.buttons[L10n.Identification.Scan.scan].wait().tap()
    }
    
    func testIdentificationScanCancels() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launchWithIdentifiedOnce()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["cancelPINScan"].wait().tap()
        app.buttons[L10n.Identification.Scan.scan].assertExistence()

    }
    
    func testIdentificationCANThirdAttemptToSuccessFullyIdentified() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launchWithIdentifiedOnce()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runCardSuspended"].wait().tap()
        
        app.buttons[L10n.Identification.Can.Intro.continue].wait().tap()
        
        let canTextField = app.secureTextFields[L10n.Identification.Can.Input.canInputLabel]
        canTextField.wait().tap()
        canTextField.waitAndTypeText("123456")
        app.buttons[L10n.Identification.Can.Input.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runCANError"].wait().tap()
        
        canTextField.wait().tap()
        canTextField.waitAndTypeText("123456")
        
        app.buttons[L10n.Identification.Can.Input.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runCANError"].wait().tap()
        
        let matchingButtons = app.navigationBars.buttons.matching(identifier: L10n.Identification.Can.IncorrectInput.back)
        matchingButtons.element(boundBy: 0).tap()
        app.staticTexts[L10n.Identification.Can.Intro.title].assertExistence()
        app.buttons[L10n.Identification.Can.Intro.continue].wait().tap()
        canTextField.wait().tap()
        canTextField.waitAndTypeText("123456")
        app.buttons[L10n.Identification.Can.Input.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["identifySuccessfully"].wait().tap()
        
        app.buttons[L10n.Home.startSetup].assertExistence()
        
        let safari = XCUIApplication(bundleIdentifier: SafariIdentifiers.bundleId.rawValue)
        XCTAssertEqual(safari.state, .runningForeground)
    }
    
    func testIdentificationCANThirdAttemptDismissesInIntro() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launchWithIdentifiedOnce()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runCardSuspended"].wait().tap()
        
        app.navigationBars.buttons[L10n.General.cancel].wait().tap()
        app.buttons[L10n.Identification.ConfirmEnd.confirm].wait().tap()
        app.staticTexts[L10n.Home.Header.title].assertExistence()
    }
    
    func testIdentificationCANDismissesScan() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launchWithIdentifiedOnce()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runCardSuspended"].wait().tap()
        
        app.buttons[L10n.Identification.Can.Intro.continue].wait().tap()
        
        let canTextField = app.secureTextFields[L10n.Identification.Can.Input.canInputLabel]
        canTextField.wait().tap()
        canTextField.waitAndTypeText("123456")
        app.buttons[L10n.Identification.Can.Input.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        
        app.navigationBars.buttons[L10n.General.cancel].wait().tap()
        app.staticTexts[L10n.Home.Header.title].assertExistence()
    }
    
    func testIdentificationCANScanCancels() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launchWithIdentifiedOnce()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runCardSuspended"].wait().tap()
        
        app.buttons[L10n.Identification.Can.Intro.continue].wait().tap()
        
        let canTextField = app.secureTextFields[L10n.Identification.Can.Input.canInputLabel]
        canTextField.wait().tap()
        canTextField.waitAndTypeText("123456")
        app.buttons[L10n.Identification.Can.Input.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["cancelCANScan"].wait().tap()
        
        app.buttons[L10n.Identification.Scan.scan].assertExistence()
    }
    
    func testIdentificationPINForgottenDismissesAfterConfirmation() throws {
        var remainingAttempts = 3
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launchWithIdentifiedOnce()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runPINError (\(remainingAttempts))"].wait().tap()
        remainingAttempts -= 1
        
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runPINError (\(remainingAttempts))"].wait().tap()
        
        app.navigationBars.buttons[L10n.General.cancel].wait().tap()
        app.buttons[L10n.Identification.ConfirmEnd.confirm].wait().tap()
        app.staticTexts[L10n.Home.Header.title].assertExistence()
    }
    
    func testIdentificationCANAfterTwoAttemptsToCardBlocked() throws {
        var remainingAttempts = 3
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launchWithIdentifiedOnce()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.AttributeConsent.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runPINError (\(remainingAttempts))"].wait().tap()
        remainingAttempts -= 1
        
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runPINError (\(remainingAttempts))"].wait().tap()
        remainingAttempts -= 1
        
        app.buttons[L10n.Identification.Can.PinForgotten.orderNewPin].wait().tap()
        app.navigationBars.buttons.element(boundBy: 0).wait().tap()
        
        app.buttons[L10n.Identification.Can.PinForgotten.retry].wait().tap()
        app.navigationBars.buttons.element(boundBy: 0).wait().tap()
        
        app.buttons[L10n.Identification.Can.PinForgotten.retry].wait().tap()
        app.buttons[L10n.Identification.Can.Intro.continue].wait().tap()
        
        let canTextField = app.secureTextFields[L10n.Identification.Can.Input.canInputLabel]
        canTextField.wait().tap()
        canTextField.waitAndTypeText("123456")
        app.toolbars["Toolbar"].buttons[L10n.Identification.Can.Input.continue].wait().tap()
        
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runCANError"].wait().tap()
        
        canTextField.wait().tap()
        canTextField.waitAndTypeText("123456")
        app.toolbars["Toolbar"].buttons[L10n.Identification.Can.Input.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runCANError"].wait().tap()
        
        let matchingButtons = app.navigationBars.buttons.matching(identifier: L10n.Identification.Can.IncorrectInput.back)
        matchingButtons.element(boundBy: 0).tap()
        
        app.buttons[L10n.Identification.Can.Intro.continue].wait().tap()
        
        canTextField.wait().tap()
        canTextField.waitAndTypeText("123456")
        app.toolbars["Toolbar"].buttons[L10n.Identification.Can.Input.continue].wait().tap()
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        app.activityIndicators["ScanProgressView"].assertExistence()
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runPINError (\(remainingAttempts))"].wait().tap()
        app.staticTexts[L10n.ScanError.CardBlocked.title].assertExistence()
    }
}
// swiftlint:enable type_body_length
