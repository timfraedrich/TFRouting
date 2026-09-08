import SwiftUI
import TFRouting

struct DemoStateInspector: View {
    
    @Environment(Router.self) private var router
    @Environment(RouterNode.self) private var node
    
    let label: String
    
    /// - note: Counted by walking ``RouterNode/parent`` upwards, which is how the demo shows that
    /// `@Environment(RouterNode.self)` resolves to a different node inside a modal or a branch.
    private var nestingLevel: Int {
        var level = 0
        var current = node.parent
        while let ancestor = current {
            level += 1
            current = ancestor.parent
        }
        return level
    }
    
    private var selectionDescription: String {
        router.root.selection?.demoDescription ?? "none"
    }
    
    private var pathDescription: String {
        node.path.isEmpty ? "empty" : "\(node.path.count) · " + node.path.map(\.demoDescription).joined(separator: " › ")
    }
    
    private var localModalDescription: String {
        Self.describe(node.modalStack)
    }
    
    private var rootModalDescription: String {
        Self.describe(router.root.modalStack)
    }
    
    private var failureDescription: String {
        router.lastFailure.map { String(describing: $0) } ?? "none"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                Text(label).bold()
                Spacer()
                Button("Clear failure") { router.lastFailure = nil }
                    .buttonStyle(.borderless)
            }
            row("nesting", "\(nestingLevel)")
            row("path", pathDescription)
            row("modals here", localModalDescription)
            row("root selection", selectionDescription)
            row("root modals", rootModalDescription)
            row("lastFailure", failureDescription)
                .foregroundStyle(router.lastFailure == nil ? AnyShapeStyle(.secondary) : AnyShapeStyle(.red))
        }
        .font(.caption2.monospaced())
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(.thinMaterial)
        .overlay(alignment: .top) { Divider() }
    }
    
    @ViewBuilder
    private func row(_ key: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: 4) {
            Text(key + ":").frame(width: 104, alignment: .leading)
            Text(value).foregroundStyle(.primary)
        }
    }
    
    private static func describe(_ stack: [RouterNode.Presented]) -> String {
        stack.isEmpty ? "none" : stack.map { "\($0.route.demoDescription) \(describe($0.presentation))" }.joined(separator: " › ")
    }
    
    private static func describe(_ presentation: RoutePresentation) -> String {
        switch presentation {
        case .push: "[push]"
        case .sheet: "[sheet]"
        case .fullScreenCover: "[cover]"
        case .selection: "[selection]"
        }
    }
}

private extension AnyRoute {
    
    var demoDescription: String {
        String(describing: base)
    }
}
