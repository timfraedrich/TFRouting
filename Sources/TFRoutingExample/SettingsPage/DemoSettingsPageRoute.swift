import SwiftUI
import TFRouting

/// - note: Claimed by no scope of its own; ``DefaultScope`` pushes it because that is its default presentation.
struct DemoSettingsPageRoute: RouteProtocol {
    
    var defaultPresentation: RoutePresentation { .push }
    
    func content(in context: RouteContext) -> some View {
        DemoSettingsPageScreen()
    }
}
