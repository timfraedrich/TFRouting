import SwiftUI

/// Decides how ``RouterHost`` presents modal routes and dresses the screens of its routes.
///
/// It is read from the environment, so a configuration set above the outermost host applies to every modal as well.
public struct RouterHostConfiguration: Sendable {

    /// Whether a modal presentation covers the full screen instead of being shown as a sheet.
    public var presentsFullScreen: @MainActor @Sendable (_ presentation: RoutePresentation) -> Bool
    /// Wraps the screen of every pushed or presented route, e.g. to style its navigation bar.
    public var decorate: @MainActor @Sendable (_ content: AnyView, _ context: RouteContext) -> AnyView

    public init(
        presentsFullScreen: @escaping @MainActor @Sendable (_ presentation: RoutePresentation) -> Bool = { $0 == .fullScreenCover },
        decorate: @escaping @MainActor @Sendable (_ content: AnyView, _ context: RouteContext) -> AnyView = { content, _ in content }
    ) {
        self.presentsFullScreen = presentsFullScreen
        self.decorate = decorate
    }
}

public extension EnvironmentValues {

    @Entry var routerHostConfiguration = RouterHostConfiguration()
}
