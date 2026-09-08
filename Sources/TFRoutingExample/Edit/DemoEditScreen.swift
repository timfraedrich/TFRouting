import SwiftUI
import TFRouting

struct DemoEditScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let id: Int
    let context: RouteContext
    
    var body: some View {
        List {
            Section {
                Text("A sheet presented from within a sheet, on the deepest node of the chain.")
            } header: {
                Text("Modal stacking")
            }
            DemoControlsSection()
        }
        .navigationTitle("Edit \(id)")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close", systemImage: "xmark") { dismiss() }
            }
        }
        .safeAreaInset(edge: .bottom) { DemoStateInspector(label: "Edit \(id) sheet — its own node") }
    }
}
