public enum RoutePresentation: Hashable, Sendable {
    
    case push
    case sheet
    case fullScreenCover
    /// Names one of the deciding context's parallel branches.
    case selection
    /// A modal presentation defined by the app, which ``RouterHost`` shows as a sheet unless its
    /// ``RouterHostConfiguration`` presents it full screen.
    case custom(CustomRoutePresentation)
    
    public var isModal: Bool {
        switch self {
        case .push, .selection: false
        case .sheet, .fullScreenCover, .custom: true
        }
    }
    
    public var isSheet: Bool {
        switch self {
        case .sheet: true
        case .push, .fullScreenCover, .selection, .custom: false
        }
    }
}
