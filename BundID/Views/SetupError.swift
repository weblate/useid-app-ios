import SwiftUI
import ComposableArchitecture

enum SetupErrorType {
    case cardDeactivated
    case cardSuspended
    case cardBlocked
}

struct SetupErrorState: Equatable {
    var errorType: SetupErrorType
    
    var title: String {
        switch errorType {
        case .cardDeactivated:
            return L10n.FirstTimeUser.Error.CardDeactivated.title
        case .cardSuspended:
            return L10n.FirstTimeUser.Error.CardSuspended.title
        case .cardBlocked:
            return L10n.FirstTimeUser.Error.CardBlocked.title
        }
    }
    
    var body: String {
        switch errorType {
        case .cardDeactivated:
            return L10n.FirstTimeUser.Error.CardDeactivated.body
        case .cardSuspended:
            return L10n.FirstTimeUser.Error.CardSuspended.body
        case .cardBlocked:
            return L10n.FirstTimeUser.Error.CardBlocked.body
        }
    }
    
    var linkMeta: LinkMeta? {
        switch errorType {
        case .cardDeactivated:
            return LinkMeta(title: L10n.FirstTimeUser.Error.CardDeactivated.Link.title, url: URL(string: L10n.FirstTimeUser.Error.CardDeactivated.Link.url)!)
        default:
            return nil
        }
    }
}

enum SetupErrorAction: Equatable {
    case done
}

struct SetupError: View {
    var store: Store<SetupErrorState, SetupErrorAction>
    
    var body: some View {
        WithViewStore(store) { viewStore in
            DialogView(store: store.stateless, titleKey: viewStore.title, bodyKey: viewStore.body, linkMeta: viewStore.linkMeta, secondaryButton: nil, primaryButton: .init(title: L10n.FirstTimeUser.Error.close, action: .done))
        }.navigationBarBackButtonHidden(true)
    }
}

struct SetupError_Previews: PreviewProvider {
    static var previews: some View {
        SetupError(store: Store(initialState: .init(errorType: .cardDeactivated),
                                reducer: .empty,
                                environment: AppEnvironment.preview))
        SetupError(store: Store(initialState: .init(errorType: .cardSuspended),
                                reducer: .empty,
                                environment: AppEnvironment.preview))
        SetupError(store: Store(initialState: .init(errorType: .cardBlocked),
                                reducer: .empty,
                                environment: AppEnvironment.preview))
    }
}
