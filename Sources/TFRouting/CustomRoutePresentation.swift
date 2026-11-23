/// Names a modal presentation defined by the app, e.g. a compact sheet or an overlay.
///
/// ```swift
/// extension CustomRoutePresentation {
///     static let compactSheet = Self("compactSheet")
/// }
/// ```
public struct CustomRoutePresentation: RawRepresentable, Hashable, Sendable {
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
}
