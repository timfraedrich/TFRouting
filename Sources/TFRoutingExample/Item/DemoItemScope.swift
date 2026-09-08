import TFRouting

struct DemoItemScope: RoutingScope {
    
    func decide(_ route: any RouteProtocol, in node: RouterNodeSnapshot) -> RoutingDecision {
        switch route {
        case is DemoEditRoute: .present(.sheet)
        default: .pass
        }
    }
}
