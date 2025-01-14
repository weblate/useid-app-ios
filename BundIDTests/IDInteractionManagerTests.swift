import XCTest
import Foundation
import OpenEcard
import Cuckoo

@testable import BundID

extension MockContextManagerType: NSObjectProtocol {
    func isEqual(_ object: Any?) -> Bool { fatalError() }
    var hash: Int { fatalError() }
    var superclass: AnyClass? { fatalError() }
    func `self`() -> Self { fatalError() }
    func perform(_ aSelector: Selector!) -> Unmanaged<AnyObject>! { fatalError() }
    func perform(_ aSelector: Selector!, with object: Any!) -> Unmanaged<AnyObject>! { fatalError() }
    func perform(_ aSelector: Selector!, with object1: Any!, with object2: Any!) -> Unmanaged<AnyObject>! { fatalError() }
    func isProxy() -> Bool { fatalError() }
    func isKind(of aClass: AnyClass) -> Bool { fatalError() }
    func isMember(of aClass: AnyClass) -> Bool { fatalError() }
    func conforms(to aProtocol: Protocol) -> Bool { fatalError() }
    func responds(to aSelector: Selector!) -> Bool { fatalError() }
    var description: String { fatalError() }
}

class IDInteractionManagerTests: XCTestCase {
    func testInitCallsContext() throws {
        let mockOpenEcard = MockOpenEcardType()
        let mockContextManager = MockContextManagerType()
        
        stub(mockOpenEcard) {
            $0.context(any()).thenReturn(mockContextManager)
        }
        
        stub(mockContextManager) {
            $0.initializeContext(any()).thenDoNothing()
        }
        
        _ = IDInteractionManager(openEcard: mockOpenEcard,
                                                      nfcMessageProvider: NFCMessageProvider())
        
        verify(mockOpenEcard).context(any())
    }
    
    func testChangePIN() throws {
        let mockOpenEcard = MockOpenEcardType()
        let mockContextManager = MockContextManagerType()
        
        stub(mockOpenEcard) {
            $0.context(any()).thenReturn(mockContextManager)
        }
        
        stub(mockContextManager) {
            $0.initializeContext(any()).thenDoNothing()
        }
        
        let interactionManager = IDInteractionManager(openEcard: mockOpenEcard,
                                                      nfcMessageProvider: NFCMessageProvider())
        
        _ = interactionManager.changePIN()
        
        let argumentCaptor = ArgumentCaptor<NSObjectProtocol & StartServiceHandlerProtocol>()
        verify(mockContextManager).initializeContext(argumentCaptor.capture())
        let argument = argumentCaptor.value as! StartServiceHandler
        
        XCTAssertEqual(argument.task, .pinManagement)
    }
}
