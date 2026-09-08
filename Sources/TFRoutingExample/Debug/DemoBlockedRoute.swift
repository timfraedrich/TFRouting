import SwiftUI
import TFRouting

struct DemoBlockedRoute: RouteProtocol {
    
    func content(in context: RouteContext) -> some View {
        Text("Never presented.")
    }
}
