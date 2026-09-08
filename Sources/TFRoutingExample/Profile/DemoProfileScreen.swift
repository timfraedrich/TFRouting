import SwiftUI
import TFRouting

struct DemoProfileScreen: View {
    
    @Environment(Router.self) private var router
    
    var body: some View {
        List {
            Section {
                Button("Open item 1") { router.route(DemoItemRoute(id: 1)) }
            } header: {
                Text("One route, two presentations")
            } footer: {
                Text("Identical call to the one in Library, decided here by DemoProfileScope as a sheet.")
            }
            Section {
                Button("Blocked route — DemoProfileScope rejects it") { router.route(DemoBlockedRoute()) }
            } header: {
                Text("Rejection")
            } footer: {
                Text("A rejection does not bubble up; the root scope never sees the route.")
            }
            Section {
                RouteLink("Settings — passed up to DemoRootScope", route: DemoSettingsRoute())
            } header: {
                Text("Bubbling")
            }
            Section {
                Button("Discard the Library branch") { router.root.discardBranch(for: DemoRootTab.library) }
            } header: {
                Text("Branches")
            } footer: {
                Text("Switch to Library afterwards: its path and modal are gone.")
            }
            DemoControlsSection()
        }
        .navigationTitle("Profile")
        .safeAreaInset(edge: .bottom) { DemoStateInspector(label: "Profile branch") }
    }
}
