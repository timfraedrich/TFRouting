import TFRouting

/// - note: ``DemoEditRoute`` is claimed here as well as by ``DemoItemScope``, because a push creates no
/// node of its own: a pushed item routes from this branch, a presented one from its own context.
struct DemoLibraryScope: RoutingScope {
    
    func decide(_ route: any RouteProtocol, in node: RouterNodeSnapshot) -> RoutingDecision {
        switch route {
        case is DemoItemRoute: .present(.push)
        case is DemoEditRoute: .present(.fullScreenCover)
        default: .pass
        }
    }
}
