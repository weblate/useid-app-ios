//
//  BundIDTests.swift
//  BundIDTests
//
//  Created by Andreas Ganske on 20.05.22.
//

import XCTest

@testable import BundID

class FirstTimeUserPersonalPINScreenViewModelTests: XCTestCase {

    func testCompletePIN1() throws {
        let viewModel = FirstTimeUserPersonalPINScreenViewModel(enteredPIN1: "12345")
        viewModel.enteredPIN1 = "123456"
        
        XCTAssertTrue(viewModel.showPIN2)
        XCTAssertFalse(viewModel.focusPIN1)
        XCTAssertTrue(viewModel.focusPIN2)
    }
    
    func testCorrectPIN2() throws {
        let viewModel = FirstTimeUserPersonalPINScreenViewModel(enteredPIN1: "123456", enteredPIN2: "12345")
        viewModel.enteredPIN2 = "123456"
        
        XCTAssertTrue(viewModel.isFinished)
        XCTAssertNil(viewModel.error)
    }
    
    func testMismatchingPIN2() throws {
        let viewModel = FirstTimeUserPersonalPINScreenViewModel(enteredPIN1: "123456", enteredPIN2: "12345")
        viewModel.enteredPIN2 = "987654"
        
        XCTAssertFalse(viewModel.isFinished)
        XCTAssertEqual(viewModel.error, .mismatch)
    }
    
    func testTypingPIN2() throws {
        let viewModel = FirstTimeUserPersonalPINScreenViewModel(enteredPIN1: "123456", enteredPIN2: "")
        viewModel.enteredPIN2 = "123"
        
        XCTAssertFalse(viewModel.isFinished)
        XCTAssertNil(viewModel.error)
    }
}