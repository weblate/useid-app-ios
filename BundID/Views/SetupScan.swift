import SwiftUI
import ComposableArchitecture
import Combine
import Lottie

enum SetupScanError: Equatable {
    case idCardInteraction(IDCardInteractionError)
    case unexpectedEvent(EIDInteractionEvent)
}

struct SetupScanState: Equatable {
    var isScanning: Bool = false
    var showProgressCaption: Bool = false
    var transportPIN: String
    var newPIN: String
    var error: SetupScanError?
    var remainingAttempts: Int?
    var attempt = 0
}

enum SetupScanAction: Equatable {
    case onAppear
    case startScan
    case scanEvent(Result<EIDInteractionEvent, IDCardInteractionError>)
    case wrongTransportPIN(remainingAttempts: Int)
    case error(SetupErrorType)
    case cancelScan
    case scannedSuccessfully
#if targetEnvironment(simulator)
    case runDebugSequence(DebugIDInteractionManager.DebugSequence)
#endif
}

let setupScanReducer = Reducer<SetupScanState, SetupScanAction, AppEnvironment> { state, action, environment in
    switch action {
#if targetEnvironment(simulator)
    case .runDebugSequence(let debugSequence):
        // swiftlint:disable:next force_cast
        (environment.idInteractionManager as! DebugIDInteractionManager).runDebugSequence(debugSequence)
        return .none
#endif
    case .onAppear:
        return Effect(value: .startScan)
    case .startScan:
        state.error = nil
        state.isScanning = true
        return environment.idInteractionManager.changePIN()
            .receive(on: environment.mainQueue)
            .catchToEffect(SetupScanAction.scanEvent)
            .cancellable(id: "ChangePIN", cancelInFlight: true)
    case .scanEvent(.failure(let error)):
        state.error = .idCardInteraction(error)
        state.isScanning = false
        
        switch error {
        case .cardDeactivated:
            return Effect(value: .error(.cardDeactivated))
        case .cardBlocked:
            return Effect(value: .error(.cardBlocked))
        default:
            return .cancel(id: "ChangePIN")
        }
    case .scanEvent(.success(let event)):
        return state.handle(event: event, environment: environment)
    case .cancelScan:
        state.isScanning = false
        return .cancel(id: "ChangePIN")
    case .error:
        return .cancel(id: "ChangePIN")
    case .wrongTransportPIN:
        return .cancel(id: "ChangePIN")
    case .scannedSuccessfully:
        return .cancel(id: "ChangePIN")
    }
}

extension SetupScanState {
    mutating func handle(event: EIDInteractionEvent, environment: AppEnvironment) -> Effect<SetupScanAction, Never> {
        switch event {
        case .authenticationStarted:
            print("Authentication started")
        case .requestCardInsertion(let messageCallback):
            self.showProgressCaption = false
            print("Request card insertion.")
            messageCallback("Request card insertion.")
        case .cardInteractionComplete: print("Card interaction complete.")
        case .cardRecognized: print("Card recognized.")
        case .cardRemoved:
            self.showProgressCaption = true
            print("Card removed.")
        case .processCompletedSuccessfully:
            return Effect(value: .scannedSuccessfully)
        case .pinManagementStarted: print("PIN Management started.")
        case .requestChangedPIN(let remainingAttempts, let pinCallback):
            print("Providing changed PIN with \(remainingAttempts ?? 3) remaining attempts.")
            let remainingAttemptsBefore = self.remainingAttempts
            self.remainingAttempts = remainingAttempts
            
            // This is our signal that the user canceled (for now)
            guard let remainingAttempts = remainingAttempts else {
                return Effect(value: .cancelScan)
            }
            
            // Wrong transport/personal PIN provided
            if let remainingAttemptsBefore = remainingAttemptsBefore,
               remainingAttempts < remainingAttemptsBefore {
                return Effect(value: .wrongTransportPIN(remainingAttempts: remainingAttempts))
            }
            
            pinCallback(transportPIN, newPIN)
        case .requestCANAndChangedPIN:
            print("CAN to change PIN requested, so card is suspended. Callback not implemented yet.")
            return Effect(value: .error(.cardSuspended))
        case .requestPUK:
            print("PUK requested, so card is blocked. Callback not implemented yet.")
            return Effect(value: .error(.cardBlocked))
        default:
            self.error = .unexpectedEvent(event)
            print("Received unexpected event.")
            return Effect(value: .cancelScan)
        }
        return .none
    }
}

extension SetupScanState {
    var errorTitle: String? {
        switch self.error {
        case .idCardInteraction:
            return L10n.FirstTimeUser.Scan.ScanError.IdCardInteraction.title
        case .unexpectedEvent:
            return L10n.FirstTimeUser.Scan.ScanError.UnexpectedEvent.title
        default:
            return nil
        }
    }

    var errorBody: String? {
        switch self.error {
        case .idCardInteraction:
            return L10n.FirstTimeUser.Scan.ScanError.IdCardInteraction.body
        case .unexpectedEvent:
            return L10n.FirstTimeUser.Scan.ScanError.UnexpectedEvent.body
        default:
            return nil
        }
    }
    
    var showLottie: Bool {
        switch self.error {
        case .unexpectedEvent:
            return false
        default:
            return true
        }
    }
}

struct SetupScan: View {
    
    var store: Store<SetupScanState, SetupScanAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    if viewStore.state.showLottie {
                        LottieView(name: "38076-id-scan")
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        Spacer()
                    }
                    
                    if let title = viewStore.state.errorTitle {
                        HeaderView(titleKey: title, bodyKey: viewStore.state.errorBody)
                    }
                }
                if viewStore.isScanning {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.blue900))
                            .scaleEffect(3)
                            .frame(maxWidth: .infinity)
                            .padding(50)
                        if viewStore.showProgressCaption {
                        	Text(L10n.FirstTimeUser.Scan.Progress.caption)
                            	.font(.bundTitle)
                            	.foregroundColor(.blackish)
                                .padding(.bottom, 50)
                        }
                    }
                } else {
                    DialogButtons(store: store.stateless,
                                  secondary: nil,
                                  primary: .init(title: L10n.FirstTimeUser.Scan.scan, action: .startScan))
                    .disabled(viewStore.isScanning)
                }
            }.onChange(of: viewStore.state.attempt, perform: { _ in
                viewStore.send(.startScan)
            })
            .onAppear {
                viewStore.send(.onAppear)
            }
#if targetEnvironment(simulator)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("NFC Error") {
                            viewStore.send(.runDebugSequence(.runNFCError))
                        }
                        Button("Incorrect transport PIN") {
                            viewStore.send(.runDebugSequence(.runTransportPINError(remainingAttempts: viewStore.remainingAttempts ?? 3)))
                        }
                        Button("Card deactivated") {
                            viewStore.send(.runDebugSequence(.runCardDeactivated))
                        }
                        Button("Card blocked") {
                            viewStore.send(.runDebugSequence(.runCardBlocked))
                        }
                        Button("Unexpected event") {
                            viewStore.send(.runDebugSequence(.runUnexpectedEvent))
                        }
                        Button("Success") {
                            viewStore.send(.runDebugSequence(.runSuccessfully))
                        }
                    } label: {
                         Image(systemName: "wrench")
                    }.disabled(!viewStore.isScanning)
                }
            }
#endif
        }
    }
}

struct SetupScan_Previews: PreviewProvider {
    static var previews: some View {
        SetupScan(store: Store(initialState: SetupScanState(transportPIN: "12345", newPIN: "123456"), reducer: .empty, environment: AppEnvironment.preview))
        SetupScan(store: Store(initialState: SetupScanState(transportPIN: "12345", newPIN: "123456", error: .idCardInteraction(.processFailed(resultCode: .INTERNAL_ERROR))), reducer: .empty, environment: AppEnvironment.preview))
        SetupScan(store: Store(initialState: SetupScanState(transportPIN: "12345", newPIN: "123456", error: .unexpectedEvent(.requestPINAndCAN({ _, _ in }))), reducer: .empty, environment: AppEnvironment.preview))
        NavigationView {
            SetupScan(store: Store(initialState: SetupScanState(isScanning: true, showProgressCaption: false, transportPIN: "12345", newPIN: "123456"), reducer: .empty, environment: AppEnvironment.preview))
        }
    }
}
