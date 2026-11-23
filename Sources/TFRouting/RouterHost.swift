import SwiftUI

public struct RouterHost<Content: View>: View {

    @Bindable var node: RouterNode
    private let showsFirstRouteAsRoot: Bool
    @ViewBuilder let content: () -> Content

    @Environment(\.routerHostConfiguration) private var configuration

    public var body: some View {
        NavigationStack(path: path) {
            root
                .navigationDestination(for: AnyRoute.self) { route in
                    screen(for: route, in: .init(presentation: .push))
                }
        }
        .environment(node)
        .sheet(item: modal { [configuration] in !configuration.presentsFullScreen($0) }) { presented in
            modalBody(presented)
        }
        .fullScreenCover(item: modal { [configuration] in configuration.presentsFullScreen($0) }) { presented in
            modalBody(presented)
        }
    }

    public init(node: RouterNode, @ViewBuilder content: @escaping () -> Content) {
        self.node = node
        self.showsFirstRouteAsRoot = false
        self.content = content
    }

    /// Hosts a node whose first route is the root of the stack instead of being pushed onto it, e.g. for a flow that
    /// replaces its only screen rather than pushing the next one.
    public init(showingFirstRouteOf node: RouterNode) where Content == EmptyView {
        self.node = node
        self.showsFirstRouteAsRoot = true
        self.content = { EmptyView() }
    }

    @ViewBuilder
    private var root: some View {
        if !showsFirstRouteAsRoot {
            content()
        } else if let first = node.path.first {
            screen(for: first, in: .init(presentation: .push))
                .id(first)
        }
    }

    private var path: Binding<[AnyRoute]> {
        guard showsFirstRouteAsRoot else { return $node.path }
        return Binding(
            get: { Array(node.path.dropFirst()) },
            set: { node.path = Array(node.path.prefix(1)) + $0 }
        )
    }

    private func screen(for route: AnyRoute, in context: RouteContext) -> AnyView {
        configuration.decorate(AnyView(RouteContentView(route: route.base, context: context)), context)
    }

    /// Hosting the presented node rather than this one is what makes `@Environment(RouterNode.self)`
    /// inside a modal resolve to the modal's own context instead of the presenting one.
    ///
    /// - note: The recursion is what allows sheets above sheets, as SwiftUI honours only a single
    /// `.sheet(item:)` per view.
    @ViewBuilder
    private func modalBody(_ presented: RouterNode.Presented) -> some View {
        // Pinning the generic parameter terminates the otherwise infinite recursive type expansion.
        RouterHost<AnyView>(node: presented.child) {
            screen(for: presented.route, in: .init(presentation: presented.presentation))
        }
        .id(presented.route.id)
    }

    private func modal(kind: @escaping (RoutePresentation) -> Bool) -> Binding<RouterNode.Presented?> {
        .init(
            get: { node.modal.flatMap { kind($0.presentation) ? $0 : nil } },
            set: { if $0 == nil, let current = node.modal, kind(current.presentation) { node.modal = nil } }
        )
    }
}
