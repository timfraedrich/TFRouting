import SwiftUI
import TFRouting

struct DemoItemScreen: View {
    
    @Environment(Router.self) private var router
    @Environment(\.dismiss) private var dismiss
    
    let id: Int
    let context: RouteContext
    
    private var inspectorLabel: String {
        context.isModalRoot ? "Item \(id) sheet — its own node" : "Item \(id) pushed — still the branch node"
    }
    
    var body: some View {
        List {
            Section {
                Text(context.isModalRoot ? "isModalRoot: true — the toolbar shows a close button." : "isModalRoot: false — pushed, so no close button.")
            } header: {
                Text("Context")
            }
            Section {
                Button("Edit item \(id)") { router.route(DemoEditRoute(id: id)) }
            } header: {
                Text("Presentations from here")
            } footer: {
                Text("Decided by DemoItemScope in the sheet and by DemoLibraryScope when pushed, since a push creates no node.")
            }
            if context.isModalRoot {
                Section {
                    Button("Open item \(id) again") { router.route(DemoItemRoute(id: id)) }
                } header: {
                    Text("presentationBusy")
                } footer: {
                    Text("The route is already in the modal chain, so it is refused instead of presented twice.")
                }
            }
            DemoControlsSection()
        }
        .navigationTitle("Item \(id)")
        .toolbar(content: toolbarContent)
        .safeAreaInset(edge: .bottom) { DemoStateInspector(label: inspectorLabel) }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        if context.isModalRoot {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close", systemImage: "xmark") { dismiss() }
            }
        }
    }
}
