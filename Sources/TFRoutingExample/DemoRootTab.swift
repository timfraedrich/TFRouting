import SwiftUI
import TFRouting

/// - note: A tab route is a ``RoutePresentation/selection`` value of the root context, and its
/// ``RouteProtocol/scope()`` becomes the scope of the branch backing that tab.
enum DemoRootTab: RouteProtocol {
    
    case library
    case profile
    
    var defaultPresentation: RoutePresentation { .selection }
    
    func content(in context: RouteContext) -> some View {
        switch self {
        case .library: DemoLibraryScreen()
        case .profile: DemoProfileScreen()
        }
    }
    
    func scope() -> (any RoutingScope)? {
        switch self {
        case .library: DemoLibraryScope()
        case .profile: DemoProfileScope()
        }
    }
}
