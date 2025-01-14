import XCTest
import ComposableArchitecture

@testable import BundID

class SetupPersonalPINViewModelTests: XCTestCase {
    
    var scheduler: TestSchedulerOf<DispatchQueue>!
    var environment: AppEnvironment!
    
    override func setUp() {
        scheduler = DispatchQueue.test
        environment = AppEnvironment(mainQueue: scheduler.eraseToAnyScheduler(),
                                     idInteractionManager: MockIDInteractionManager(queue: scheduler.eraseToAnyScheduler()))
    }
    
    func testCompletePIN1() throws {
        let store = TestStore(initialState: SetupPersonalPINState(enteredPIN1: "12345"),
                              reducer: setupPersonalPINReducer,
                              environment: environment)
        
        store.send(.binding(.set(\.$enteredPIN1, "123456"))) { state in
            state.enteredPIN1 = "123456"
            state.showPIN2 = true
            state.focusPIN2 = true
        }
    }
    
    func testCorrectPIN2() throws {
        let store = TestStore(initialState: SetupPersonalPINState(enteredPIN1: "123456",
                                                                          enteredPIN2: "12345",
                                                                          showPIN2: true),
                              reducer: setupPersonalPINReducer,
                              environment: environment)
        store.send(.binding(.set(\.$enteredPIN2, "123456"))) { state in
            state.enteredPIN2 = "123456"
        }
        store.receive(.done(pin: "123456"))
    }

    func testMismatchingPIN2() throws {
        let store = TestStore(initialState: SetupPersonalPINState(enteredPIN1: "123456",
                                                                          enteredPIN2: "98765",
                                                                          showPIN2: true),
                              reducer: setupPersonalPINReducer,
                              environment: environment)
        store.send(.binding(.set(\.$enteredPIN2, "987654"))) { state in
            state.enteredPIN2 = "987654"
            state.remainingAttempts = 1
        }
        
        scheduler.advance(by: 0.2)
        
        store.receive(.reset) { state in
            state.error = .mismatch
            state.showPIN2 = false
            state.enteredPIN2 = ""
            state.enteredPIN1 = ""
            state.focusPIN1 = true
        }
    }
    
    func testTypingWhileShowingError() throws {
        let store = TestStore(initialState: SetupPersonalPINState(enteredPIN1: "",
                                                                          error: .mismatch),
                              reducer: setupPersonalPINReducer,
                              environment: environment)
        store.send(.binding(.set(\.$enteredPIN1, "1"))) { state in
            state.enteredPIN1 = "1"
            state.error = nil
        }
    }
}
