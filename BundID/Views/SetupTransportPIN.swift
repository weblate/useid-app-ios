import SwiftUI
import ComposableArchitecture
import FlowStacks
import TCACoordinators
import IdentifiedCollections

struct SetupTransportPINState: Equatable {
    @BindableState var enteredPIN: String = ""
    @BindableState var focusTextField: Bool = true
}

enum SetupTransportPINAction: BindableAction, Equatable {
    case done(transportPIN: String)
    case binding(BindingAction<SetupTransportPINState>)
}

let setupTransportPINReducer = Reducer<SetupTransportPINState, SetupTransportPINAction, AppEnvironment> { _, _, _ in
    return .none
}.binding()

struct SetupTransportPIN: View {
    
    var store: Store<SetupTransportPINState, SetupTransportPINAction>
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    WithViewStore(store) { viewStore in
                        Text(L10n.FirstTimeUser.TransportPIN.title)
                            .font(.bundLargeTitle)
                            .foregroundColor(.blackish)
                        ZStack {
                            Image(decorative: "Transport-PIN")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            PINEntryView(pin: viewStore.binding(\.$enteredPIN),
                                         maxDigits: 5,
                                         label: L10n.FirstTimeUser.TransportPIN.textFieldLabel,
                                         shouldBeFocused: viewStore.binding(\.$focusTextField),
                                         doneConfiguration: DoneConfiguration(enabled: viewStore.enteredPIN.count == 5,
                                                                              title: L10n.FirstTimeUser.TransportPIN.continue,
                                                                              handler: { pin in
                                    viewStore.send(.done(transportPIN: pin))
                            }))
                            .font(.bundTitle)
                            .background(
                                Color.white.cornerRadius(10)
                            )
                            .padding(40)
                            // Focus: iOS 15 only
                            // Done button above keyboard: iOS 15 only
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SetupTransportPIN_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SetupTransportPIN(store: Store(initialState: .init(),
                                                         reducer: .empty,
                                                         environment: AppEnvironment.preview))
        }
        .previewDevice("iPhone SE (2nd generation)")
        NavigationView {
            SetupTransportPIN(store: Store(initialState: .init(enteredPIN: "12345"),
                                                         reducer: .empty,
                                                         environment: AppEnvironment.preview))
        }
        .previewDevice("iPhone SE (2nd generation)")
    }
}
