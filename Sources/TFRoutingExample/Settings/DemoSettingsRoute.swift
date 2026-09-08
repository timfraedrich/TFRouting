import SwiftUI
import TFRouting

struct DemoSettingsRoute: RouteProtocol {
    
    func content(in context: RouteContext) -> some View {
        DemoSettingsScreen(context: context)
    }
}
