import SwiftUI
import TFRouting

/// The headline of this demo: one declaration, pushed by ``DemoLibraryScope`` and presented as a sheet
/// by ``DemoProfileScope``.
struct DemoItemRoute: RouteProtocol {
    
    let id: Int
    
    func content(in context: RouteContext) -> some View {
        DemoItemScreen(id: id, context: context)
    }
    
    func scope() -> (any RoutingScope)? {
        DemoItemScope()
    }
}
