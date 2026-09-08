import TFRouting

struct DemoRootScope: RoutingScope {
    
    func decide(_ route: any RouteProtocol, in node: RouterNodeSnapshot) -> RoutingDecision {
        switch route {
        case is DemoRootTab: .present(.selection)
        case is DemoSettingsRoute: .present(.sheet)
        default: .pass
        }
    }
}
