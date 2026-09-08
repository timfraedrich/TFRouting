import SwiftUI
import TFRouting

struct DemoSettingsPageScreen: View {
    
    var body: some View {
        List {
            Section {
                Text("A push adds to the path of the node it was routed from, so the inspector below still shows the settings sheet's node.")
            } header: {
                Text("Same node, longer path")
            }
            DemoControlsSection()
        }
        .navigationTitle("Settings page")
        .safeAreaInset(edge: .bottom) { DemoStateInspector(label: "Settings sheet — its own node") }
    }
}
