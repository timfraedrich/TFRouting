//
//  DemoSettingsScreen.swift
//  TFRouting
//
//  Created by Tim Fraedrich on 08.09.26.
//


import SwiftUI
import TFRouting

struct DemoSettingsScreen: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let context: RouteContext
    
    var body: some View {
        List {
            Section {
                Text("Triggered inside a tab, passed on by that tab's scope and claimed by DemoRootScope.")
            } header: {
                Text("Bubbling")
            }
            Section {
                RouteLink("Settings page", route: DemoSettingsPageRoute())
            } header: {
                Text("Push inside a modal")
            } footer: {
                Text("No scope claims this route; DefaultScope pushes it because that is its default presentation.")
            }
            DemoControlsSection()
        }
        .navigationTitle("Settings")
        .toolbar(content: toolbarContent)
        .safeAreaInset(edge: .bottom) { DemoStateInspector(label: "Settings sheet — its own node") }
    }
    
    @ToolbarContentBuilder
    private func toolbarContent() -> some ToolbarContent {
        if context.isModalRoot {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close", systemImage: "xmark") { dismiss() }
            }
        }
    }
}