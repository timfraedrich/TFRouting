import SwiftUI
import TFRouting

struct DemoControlsSection: View {
    
    @Environment(Router.self) private var router
    @Environment(RouterNode.self) private var node
    
    var body: some View {
        Section {
            Button("pop()") { node.pop() }
            Button("popToRoot()") { node.popToRoot() }
            Button("dismissModals(from: 1)") { router.root.dismissModals(from: 1) }
            Button("dismissAll()") { router.root.dismissAll() }
        } header: {
            Text("Controls")
        } footer: {
            Text("pop and popToRoot act on the nearest node; the dismissals act on the root and walk the whole chain.")
        }
    }
}
