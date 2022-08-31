import SwiftUI
import ComposableArchitecture

struct HomeState: Equatable {
    var appVersion: String
    var buildNumber: Int
    var tokenURL: String?
}

enum HomeAction: Equatable {
    case triggerSetup
    case triggerIdentification(tokenURL: String)
}

struct HomeView: View {
    
    var viewStore: ViewStore<HomeState, HomeAction>
    
    init(store: Store<HomeState, HomeAction>) {
        self.viewStore = ViewStore(store)
    }
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    headerView
                        .padding(.bottom)
                        .background(Color.blue200)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text(L10n.Home.More.title)
                                .font(.title)
                                .bold()
                            Spacer()
                        }
                        setupActionView
                        listView
                        Spacer(minLength: 0)
                        Text(L10n.Home.version(version))
                            .font(.bundCaption2)
                            .padding(.bottom)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationBarHidden(true)
            .ignoresSafeArea(.container, edges: .top)
        }
    }
    
    @ViewBuilder
    var headerView: some View {
        VStack {
            ImageMeta(asset: Asset.abstractWidget).image
                .resizable()
                .aspectRatio(contentMode: .fit)
#if PREVIEW
            Button {
                viewStore.send(.triggerIdentification(tokenURL: viewStore.tokenURL ?? demoTokenURL))
            } label: {
                Text(L10n.Home.Header.title)
                    .font(.title)
                    .bold()
            }
            .buttonStyle(.plain)
            .padding(.bottom)
#else
            Text(L10n.Home.Header.title)
                .font(.title)
                .bold()
#endif
            Text(L10n.Home.Header.infoText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    var setupActionView: some View {
        ZStack {
            ImageMeta(asset: Asset.eiDs).image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding()
            VStack {
                Spacer(minLength: 160)
                Button {
                    viewStore.send(.triggerSetup)
                } label: {
                    Text(L10n.Home.Actions.setup)
                }
                .padding()
                .buttonStyle(BundButtonStyle(isPrimary: true))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.04), radius: 32, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray300, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    var listView: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                NavigationLink {
                    LicensesView()
                        .navigationTitle(L10n.Home.Actions.licenses)
                        .ignoresSafeArea()
                } label: {
                    Text(L10n.Home.Actions.licenses)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                Divider()
                    .foregroundColor(.gray300)
                    .padding(.vertical, 16)
                NavigationLink {
                    HTMLView(title: L10n.Accessibility.title,
                             html: L10n.Accessibility.Html.text)
                } label: {
                    Text(L10n.Home.Actions.accessibilityStatement)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                Divider()
                    .foregroundColor(.gray300)
                    .padding(.vertical, 16)
                NavigationLink {
                    HTMLView(title: L10n.TermsOfUse.title,
                             html: L10n.TermsOfUse.Html.text)
                } label: {
                    Text(L10n.Home.Actions.terms)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
                Divider()
                    .foregroundColor(.gray300)
                    .padding(.vertical, 16)
                NavigationLink {
                    HTMLView(title: L10n.Imprint.title,
                             html: L10n.Imprint.Html.text)
                } label: {
                    Text(L10n.Home.Actions.imprint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                }
            }
            .padding(24)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.04), radius: 32, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray300, lineWidth: 1)
        )
    }
    
    var version: String {
        let appVersion = "\(viewStore.appVersion) - \(viewStore.buildNumber)"
#if PREVIEW
        return "\(appVersion) (\(environment))"
#else
        return appVersion
#endif
    }
    
    var environment: String {
#if PREVIEW
        return "PREVIEW"
#else
        return "PRODUCTION"
#endif
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Store(initialState: HomeState(appVersion: "1.2.3",
                                                      buildNumber: 42),
                              reducer: .empty,
                              environment: AppEnvironment.preview))
    }
}