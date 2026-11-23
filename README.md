# TFRouting

This Swift-Package aims to provide an easier approach to routing in iOS apps. It replaces manual presentation and state management with abstract and flexible hierarchy definitions.

## Why should you use this library?

### The presentation is context dependent

Most routing libraries let a route say "I am a sheet". This library inverts that: a `RoutingScope` sitting in the tree answers `decide(_:in:)` and returns a `RoutePresentation`. The same `Route` can be pushed onto the navigation stack on one screen and be presented as a sheet on another. The behaviour is controlled through a `RoutingScope` which defines how a route should be handled, e.g.:

```swift
struct RootScope: RoutingScope {
    
    func decide(_ route: any RouteProtocol, in node: RouterNodeSnapshot) -> RoutingDecision {
        switch route {
        case is ItemRoute: .present(.push)
        case is CalendarRoute: .present(.sheet)
        default: .pass
        }
    }
}
```

In this example an item screen is pushed onto the navigation stack while a calendar is presented as a modal sheet. The routes define the view that is presented when they get presented:

```swift
struct ItemRoute: RouteProtocol {
    
    let id: Int
    
    func content(in context: RouteContext) -> some View {
        DemoItemScreen(id: id, context: context)
    }
}
```

This mechanic is what makes routes genuinely reusable, they do not a export a presentation policy, but rather get handled by the current scope.

### Routing bubbles like a responder chain

A route's resolution typically starts at the innermost active context (the deepest presented modal or selected branch) and works outward:

| `RoutingDecision` | Effect |
|----------|--------|
| `.present(_)` | The context claims the route and presents it. |
| `.pass` | The parent context is asked next. |
| `.reject(_)` | Resolution stops here. It does **not** bubble up. |

A settings route triggered deep inside a tab can be claimed by the root scope and presented app-wide, while a route a scope explicitly rejects never reaches the root. Local features stay local; global presentations stay global.

### No manual presentation

You only need to define a `RouterHost`-View in your hierarchy, the rest is handled automatically from there. The navigation stack, sheets and full-screen covers automatically resolve from there.

```swift
struct MyApp: App {
    
    @State private var router = Router(scope: RootScope())
    
    var body: some Scene {
        WindowGroup {
            RouterHost(node: router.root) {
                // View Content
            }
        }
    }
}
```

### Routing is completely seperate from your UI

`Router.root` exists from launch. Routes resolve entirely against the model. No view needs to have been created. Deep links are therefore not a special case with a manual replay mechanism; they are one call:

```swift
router.open([TabRoute.profile, ItemRoute(id: 7), EditRoute(id: 7)])
```

This resets the tree, then walks the program down it: select the tab, enter its branch, present the item, present the edit sheet on top. The UI catches up rather than having to already be loaded.

### Parallel branches keep their state

Tabs (and anything else selection-driven) are backed by branch nodes created on first use and retained afterwards. Push three screens in one tab, switch away, switch back: the path is intact. You can reset it deliberately with `discardBranch(for:)`.

### The nearest context is what you get

`@Environment(RouterNode.self)` inside a sheet resolves to *that sheet's* context, not the presenting one. `pop()` and `popToRoot()` therefore always act on the stack the caller is actually in, with no plumbing.

### Failures are values, not silent no-ops

Every routing call returns a `RouteResolution`. When nothing claims a route you get `.failed(.noHandler(routeType:))`; presenting a route that is already in the modal chain gives `.failed(.presentationBusy)` instead of a duplicate presentation. The last failure is also observable on the router, which makes misconfigured scopes visible during development instead of mysterious in production.

### Screens know how they are being shown

Content is built with a `RouteContext`, so one screen implementation can render a close button when it is a modal root and omit it when it was pushed — without duplicating the view.

### Modern Swift, small surface

Swift 6.2 with strict concurrency, `@Observable` and `@MainActor` throughout, `Sendable` value-typed routes, `async`/`await` idioms and no Combine. No third-party dependencies. Type erasure is deliberately confined to screen roots — never inside a `ForEach` or a list row.

---

## Core types

| Type | Role |
|------|------|
| `RouteProtocol` | A destination. Declares its SwiftUI content, an optional default presentation and an optional child scope. |
| `RoutingScope` | Answers `decide(_:in:)` with `.present`, `.pass` or `.reject`. The policy layer. |
| `Router` | Owns the root node and records the last failure. |
| `RouterNode` | One presentation context: a navigation stack, a modal slot, a selection and its branches. |
| `RouterHost` | The SwiftUI host for a node. Provides the stack, the sheet and the cover. |
| `RouteContext` | How the current screen is being presented (`isModalRoot`). |
| `RouteLink` | A navigation-styled button that routes through the scopes. |
| `RouteResolution` / `RoutingError` | The typed outcome of a routing call. |

---

## Usage

### 1. Declare a route

Routes are plain `Hashable`, `Sendable` values that carry their own view. Identity comes from the value itself.

```swift
struct ItemRoute: RouteProtocol {

    let id: Int

    func content(in context: RouteContext) -> some View {
        ItemScreen(id: id, isModal: context.isModalRoot)
    }

    /// Optional: the scope that governs routing *from* this screen once it owns a context.
    func scope() -> (any RoutingScope)? {
        ItemScope()
    }
}
```

### 2. Declare the policy

```swift
struct LibraryScope: RoutingScope {

    func decide(_ route: any RouteProtocol, in node: RouterNodeSnapshot) -> RoutingDecision {
        switch route {
        case is ItemRoute: .present(.push)
        case is EditRoute: .present(.fullScreenCover)
        default: .pass // ask the parent
        }
    }
}

struct RootScope: RoutingScope {

    func decide(_ route: any RouteProtocol, in node: RouterNodeSnapshot) -> RoutingDecision {
        switch route {
        case is LibraryRoute: .present(.selection)
        case is SettingsRoute: .present(.sheet)
        default: .pass
        }
    }
}
```

The snapshot gives the scope the context's current `path` and whether it is already presenting, so decisions can depend on state — e.g. push while the stack is shallow, present once it is deep.

### 3. Host it

```swift
struct AppScene: View {

    @State private var router = Router(scope: RootScope())

    var body: some View {
        RouterHost(node: router.root) {
            HomeScreen()
        }
        .environment(router)
    }
}
```

### 4. Navigate

```swift
struct HomeScreen: View {

    @Environment(Router.self) private var router
    @Environment(RouterNode.self) private var node

    var body: some View {
        List {
            // Asks the scopes; presentation decided by the tree.
            Button("Open item") { router.route(ItemRoute(id: 1)) }

            // Same thing, with list-row navigation styling.
            RouteLink("Open item", route: ItemRoute(id: 2))

            // Bypasses the scopes: always a push onto the enclosing stack.
            NavigationLink(route: ItemRoute(id: 3)) { Text("Open item") }

            Button("Back") { node.pop() }
        }
    }
}
```

### 5. Tabs as parallel branches

A tab is simply a route whose presentation is `.selection`; its `scope()` becomes the policy of the branch behind it.

```swift
@Bindable var root = router.root

TabView(selection: $root.selection) {
    Tab("Library", systemImage: "books.vertical", value: TabRoute.library.eraseToAnyRoute()) {
        RouterHost(node: root.branch(for: TabRoute.library)) {
            RouteContentView(route: TabRoute.library, context: .init(presentation: .selection))
        }
    }
    Tab("Profile", systemImage: "person.crop.circle", value: TabRoute.profile.eraseToAnyRoute()) {
        RouterHost(node: root.branch(for: TabRoute.profile)) {
            RouteContentView(route: TabRoute.profile, context: .init(presentation: .selection))
        }
    }
}
.environment(router)
```

### 6. Deep links

```swift
.onOpenURL { url in
    guard let program = DeepLinkParser.program(for: url) else { return }
    router.open(program) // [any RouteProtocol]
}
```

`open(_:)` dismisses everything, pops to root and then applies the program step by step, stopping and reporting if a step cannot be resolved.

### 7. Handle failures

```swift
switch router.route(SomeRoute()) {
case .resolved(let presentation):
    log("presented as \(presentation)")
case .failed(let error):
    log("routing failed: \(error)")   // .noHandler(routeType:) or .presentationBusy
}

// Or observe it:
if let failure = router.lastFailure { … }
```

### 8. Dismissal

```swift
node.pop()                        // one screen off the nearest stack
node.popToRoot()                  // clear the nearest stack
router.root.dismissModals(from: 1) // truncate the modal chain
router.root.dismissAll()          // close every modal in the chain
```

### 9. Customization

- `RoutePresentation.custom(_:)` names presentations defined by the app, e.g. a compact sheet.
- `RouterHostConfiguration`, set with `.environment(\.routerHostConfiguration, …)`, decides which modal presentations
  cover the full screen and wraps the screen of every route, e.g. to style its navigation bar.
- `RouterHost(showingFirstRouteOf:)` shows the first route of a node as the root of its stack instead of pushing it.
- `RouterNode.activeNode` is the innermost context along the routing chain, the one the user currently sees.
- Opening a program through a selection resets the selected branch, just like the root is reset.

---

## Demo

The package ships a `TFRoutingExample` target with a runnable `DemoRoutingScene`. It demonstrates one route presented two different ways depending on the tab, bubbling, rejection, nested modals, branch retention and deep linking, with a live state inspector pinned to the bottom of every screen. Open it in an Xcode preview.

---

## Requirements

| | |
|---|---|
| Platforms | iOS 18+ |
| Swift | 6.2+ |
| Xcode | 26+ |
| Dependencies | None |

---

## Installation

TFRouting is distributed exclusively via **Swift Package Manager**.

### Xcode

*File → Add Package Dependencies…*, then enter:

```
https://github.com/timfraedrich/TFRouting.git
```

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/timfraedrich/TFRouting.git", from: "1.0.0")
]
```

and add it to your target:

```swift
.target(
    name: "MyApp",
    dependencies: ["TFRouting"]
)
```

Then just:

```swift
import TFRouting
```

---

## License

TFRouting is released under the **MIT License**. See [LICENSE](LICENSE) for the full text.
