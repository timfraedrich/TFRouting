import TFRouting

struct DemoProfileScope: RoutingScope {
    
    func decide(_ route: any RouteProtocol, in node: RouterNodeSnapshot) -> RoutingDecision {
        switch route {
        case is DemoItemRoute: .present(.sheet)
        case is DemoBlockedRoute: .reject(.noHandler(routeType: String(describing: type(of: route))))
        default: .pass
        }
    }
}
