import SwiftUI
import TFRouting

struct DemoEditRoute: RouteProtocol {
    
    let id: Int
    
    func content(in context: RouteContext) -> some View {
        DemoEditScreen(id: id, context: context)
    }
}
