import Foundation
import Combine
import OpenEcard

class ControllerCallback: NSObject, ControllerCallbackType {
    
    private let subject = PassthroughSubject<EIDInteractionEvent, IDCardInteractionError>()
    
    var publisher: EIDInteractionPublisher { subject.eraseToAnyPublisher() }
    
    func onStarted() {
        subject.send(.authenticationStarted)
    }
    
    func onAuthenticationCompletion(_ result: (NSObjectProtocol & ActivationResultProtocol)!) {
        switch result.getCode() {
        case .OK:
            subject.send(.processCompletedSuccessfullyWithoutRedirect)
            subject.send(completion: .finished)
        case .REDIRECT:
            subject.send(.processCompletedSuccessfullyWithRedirect(url: result.getRedirectUrl()))
            subject.send(completion: .finished)
        case .INTERRUPTED:
            break
        default:
            subject.send(completion: .failure(.processFailed(resultCode: result.getCode())))
        }
    }
}
