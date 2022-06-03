import ComposableArchitecture
import FlowStacks
import TCACoordinators
import IdentifiedCollections

struct CoordinatorState: Equatable, IndexedRouterState {
    var transportPIN: String = ""
    var routes: [Route<ScreenState>]
}

enum CoordinatorAction: IndexedRouterAction {
    case routeAction(Int, action: ScreenAction)
    case updateRoutes([Route<ScreenState>])
}

let coordinatorReducer: Reducer<CoordinatorState, CoordinatorAction, AppEnvironment> = screenReducer
    .forEachIndexedRoute(environment: { $0 })
    .withRouteReducer(
        Reducer { state, action, _ in
            switch action {
            case .routeAction(_, ScreenAction.home(.triggerSetup)):
                state.routes.presentSheet(.setupIntro, embedInNavigationView: true)
            case .routeAction(_, ScreenAction.setupIntro(.chooseNo)):
                state.routes.push(.setupTransportPINIntro)
            case .routeAction(_, .setupTransportPINIntro(.chooseHasPINLetter)):
                state.routes.push(.setupTransportPIN(SetupTransportPINState()))
            case .routeAction(_, .setupTransportPINIntro(.chooseHasNoPINLetter)):
                print("Not implemented")
            case .routeAction(_, ScreenAction.setupIntro(.chooseYes)):
                print("Not implemented")
            case .routeAction(_, ScreenAction.setupTransportPIN(SetupTransportPINAction.done(let transportPIN))):
                state.transportPIN = transportPIN
                state.routes.push(.setupPersonalPINIntro)
            case .routeAction(_, ScreenAction.setupPersonalPINIntro(.continue)):
                state.routes.push(.setupPersonalPIN(SetupPersonalPINState()))
            case .routeAction(_, action: ScreenAction.setupPersonalPIN(SetupPersonalPINAction.done(pin: let pin))):
                state.routes.push(.setupScan(SetupScanState(transportPIN: state.transportPIN, newPIN: pin)))
            case .routeAction(_, action: ScreenAction.setupScan(.scannedSuccessfully)):
                state.routes.push(.setupDone)
            case .routeAction(_, action: ScreenAction.setupScan(.wrongTransportPIN(attempts: let attempts))):
                state.routes.presentSheet(.setupTransportPIN(SetupTransportPINState(remainingAttempts: attempts, previouslyUnsuccessful: true)), embedInNavigationView: true)
            case .routeAction(_, action: ScreenAction.setupDone(.done)):
                state.routes.dismiss()
            default:
                break
            }
            return .none
        }
    ).debug()
