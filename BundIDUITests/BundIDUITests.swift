import XCTest

final class BundIDUITests: XCTestCase {

    func testFirstTimeUserHappyPath() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithResetUserDefaults()
        app.launch()
        
        app.buttons[L10n.FirstTimeUser.Intro.no].wait().tap()
        app.buttons[L10n.FirstTimeUser.PinLetter.yes].wait().tap()
        
        let transportPINTextField = app.textFields[L10n.FirstTimeUser.TransportPIN.textFieldLabel]
        transportPINTextField.wait().tap()
        transportPINTextField.waitAndTypeText("12345")
        
        app.toolbars["Toolbar"].buttons[L10n.FirstTimeUser.TransportPIN.continue].wait().tap()
        app.buttons[L10n.FirstTimeUser.PersonalPINIntro.continue].wait().tap()
        
        let pin1TextField = app.secureTextFields[L10n.FirstTimeUser.PersonalPIN.TextFieldLabel.first]
        pin1TextField.wait().tap()
        pin1TextField.waitAndTypeText("123456")
        
        let pin2TextField = app.secureTextFields[L10n.FirstTimeUser.PersonalPIN.TextFieldLabel.second]
        pin2TextField.wait().tap()
        pin2TextField.waitAndTypeText("123456")
        
        app.buttons[L10n.FirstTimeUser.Scan.scan].wait().tap()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["changePINSuccessfully"].wait().tap()
        
        app.staticTexts[L10n.FirstTimeUser.Done.title].assertExistence()
        
        app.buttons[L10n.FirstTimeUser.Done.close].wait().tap()
        
        app.buttons[L10n.Home.Actions.setup].assertExistence()
    }
    
    func testLaunchSetupManually() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launch()
        
        app.buttons[L10n.Home.Actions.setup].wait().tap()
        app.staticTexts[L10n.FirstTimeUser.Intro.title].assertExistence()
    }
    
    func testSetupWrongTransportPINAndEndEarly() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launch()
        
        app.buttons[L10n.Home.Actions.setup].wait().tap()
        app.buttons[L10n.FirstTimeUser.Intro.no].wait().tap()
        app.buttons[L10n.FirstTimeUser.PinLetter.yes].wait().tap()
        
        let transportPINTextField = app.textFields[L10n.FirstTimeUser.TransportPIN.textFieldLabel]
        transportPINTextField.wait().tap()
        transportPINTextField.waitAndTypeText("12345")
        
        app.toolbars["Toolbar"].buttons[L10n.FirstTimeUser.TransportPIN.continue].wait().tap()
        app.buttons[L10n.FirstTimeUser.PersonalPINIntro.continue].wait().tap()
        
        let pin1TextField = app.secureTextFields[L10n.FirstTimeUser.PersonalPIN.TextFieldLabel.first]
        pin1TextField.wait().tap()
        pin1TextField.waitAndTypeText("123456")
        
        let pin2TextField = app.secureTextFields[L10n.FirstTimeUser.PersonalPIN.TextFieldLabel.second]
        pin2TextField.wait().tap()
        pin2TextField.waitAndTypeText("123456")
        
        app.buttons[L10n.FirstTimeUser.Scan.scan].wait().tap()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["runPINError"].wait().tap()
        
        app.staticTexts[L10n.FirstTimeUser.IncorrectTransportPIN.title].assertExistence()
        
        app.buttons[L10n.FirstTimeUser.IncorrectTransportPIN.end].wait().tap()
        
        app.buttons[L10n.FirstTimeUser.ConfirmEnd.confirm].wait().tap()
        
        app.buttons[L10n.Home.Actions.setup].assertExistence()
    }
    
    func testIdentificationTriggersSetupForFirstTimeUsers() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithResetUserDefaults()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.staticTexts[L10n.FirstTimeUser.Intro.title].assertExistence()
    }
    
    func testIdentificationHappyPath() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.staticTexts["Subject"].assertExistence()
        app.staticTexts[L10n.CardAttribute.dg04].assertExistence()
        
        app.buttons[L10n.Identification.Overview.Loaded.moreInfo("Subject")].wait().tap()
        
        app.staticTexts[L10n.Identification.About.terms].assertExistence()
        app.navigationBars.buttons.firstMatch.wait().tap()
        
        app.buttons[L10n.Identification.Overview.Loaded.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        
        app.buttons[L10n.Identification.Scan.scan].tap()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["identifySuccessfullyWithRedirect"].wait().tap()
        
        app.staticTexts[L10n.Identification.Done.title].assertExistence()
        
        app.buttons[L10n.Identification.Done.close].wait().tap()
        
        app.buttons[L10n.Home.Actions.setup].assertExistence()
        
        let safari = XCUIApplication(bundleIdentifier: SafariIdentifiers.bundleId.rawValue)
        XCTAssertEqual(safari.state, .runningForeground)
    }
    
    func testIdentificationLoadError() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["loadError"].wait().tap()
        
        app.buttons[L10n.Identification.Overview.Error.retry].wait().tap()
        
        app.staticTexts[L10n.Identification.Overview.loading].assertExistence()
    }
    
    func testIdentificationScanHelp() throws {
        let app = XCUIApplication()
        app.launchWithDefaultArguments()
        app.launchWithSetupCompleted()
        app.launchWithDemoTokenURL()
        app.launch()
        
        app.navigationBars.buttons["Debug"].wait().tap()
        app.buttons["requestAuthorization"].wait().tap()
        
        app.buttons[L10n.Identification.Overview.Loaded.continue].wait().tap()
        
        let pinTextField = app.secureTextFields[L10n.Identification.PersonalPIN.textFieldLabel]
        pinTextField.wait().tap()
        pinTextField.waitAndTypeText("123456")
        
        app.toolbars["Toolbar"].buttons[L10n.Identification.PersonalPIN.continue].wait().tap()
        
        app.buttons[L10n.General.Scan.help].tap()
        
        app.staticTexts[L10n.ScanError.CardUnreadable.title].assertExistence()
        app.buttons[L10n.ScanError.close].tap()
        
        app.buttons[L10n.Identification.Scan.scan].assertExistence()
        app.buttons[L10n.Identification.Scan.scan].tap()
    }
}
