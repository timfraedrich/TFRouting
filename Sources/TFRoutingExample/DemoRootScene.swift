import SwiftUI
import TFRouting

struct DemoRootScene: View {
    
    @State private var router = Router(scope: DemoRootScope())
    
    var body: some View {
        @Bindable var root = router.root
        TabView(selection: $root.selection) {
            Tab("Library", systemImage: "books.vertical", value: DemoRootTab.library.eraseToAnyRoute()) {
                branchHost(for: DemoRootTab.library)
            }
            Tab("Profile", systemImage: "person.crop.circle", value: DemoRootTab.profile.eraseToAnyRoute()) {
                branchHost(for: DemoRootTab.profile)
            }
        }
        .environment(router)
        .task {
            guard router.root.selection == nil else { return }
            router.route(DemoRootTab.library)
        }
    }
    
    @ViewBuilder
    private func branchHost(for tab: any RouteProtocol) -> some View {
        RouterHost(node: router.root.branch(for: tab)) {
            RouteContentView(route: tab, context: .init(presentation: .selection))
        }
    }
}

#Preview {
    DemoRootScene()
}
