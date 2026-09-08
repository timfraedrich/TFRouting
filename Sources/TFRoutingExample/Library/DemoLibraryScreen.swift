import SwiftUI
import TFRouting

struct DemoLibraryScreen: View {
    
    @Environment(Router.self) private var router
    
    var body: some View {
        List {
            Section {
                Button("Open item 1") { router.route(DemoItemRoute(id: 1)) }
            } header: {
                Text("One route, two presentations")
            } footer: {
                Text("DemoLibraryScope pushes DemoItemRoute. The same button in Profile presents it as a sheet.")
            }
            Section {
                RouteLink("Item 2 via RouteLink", route: DemoItemRoute(id: 2))
                NavigationLink(route: DemoItemRoute(id: 3)) {
                    Text("Item 3 via NavigationLink(route:)")
                }
            } header: {
                Text("Links")
            } footer: {
                Text("RouteLink asks the scopes. NavigationLink(route:) appends to this stack directly and bypasses them.")
            }
            Section {
                RouteLink("Settings — passed up to DemoRootScope", route: DemoSettingsRoute())
                Button("Deep link: Profile → item 7 → edit 7") { router.open(Self.deepLink) }
            } header: {
                Text("Other presentations")
            } footer: {
                Text("The deep link runs open([…]) as one program: selection, then branch, then modal, then its modal.")
            }
            Section {
                Button("Blocked route — no scope claims it here") { router.route(DemoBlockedRoute()) }
            } header: {
                Text("Failures")
            } footer: {
                Text("Watch lastFailure in the inspector below.")
            }
            Section {
                Button("Discard the Profile branch") { router.root.discardBranch(for: DemoRootTab.profile) }
            } header: {
                Text("Branches")
            } footer: {
                Text("Push an item, switch to Profile and back: the path survives. Discarding a branch resets it, visible after switching to that tab.")
            }
            DemoControlsSection()
        }
        .navigationTitle("Library")
        .safeAreaInset(edge: .bottom) { DemoStateInspector(label: "Library branch") }
    }
    
    private static let deepLink: [any RouteProtocol] = [DemoRootTab.profile, DemoItemRoute(id: 7), DemoEditRoute(id: 7)]
}
