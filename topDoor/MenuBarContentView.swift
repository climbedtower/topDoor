//
//  MenuBarContentView.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import SwiftUI

struct MenuBarContentView: View {
    @EnvironmentObject private var appState: AppState
    private let launcher = ProjectLauncher()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Content
            contentView
            
            Divider()
            
            // Footer
            footerView
        }
        .frame(width: 300, height: 400)
        .background(Color(NSColor.controlBackgroundColor))
        .onAppear {
            loadConfigIfNeeded()
        }
    }
    
    @ViewBuilder
    private var headerView: some View {
        HStack {
            Image(systemName: "hammer.circle")
                .foregroundColor(.blue)
                .font(.title2)
            Text("topDoor")
                .font(.headline)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private var contentView: some View {
        if appState.isLoading {
            loadingView
        } else if appState.projects.isEmpty {
            emptyStateView
        } else {
            projectListView
        }
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading configuration...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "folder.badge.plus")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("No Projects Found")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Add projects to your config file")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private var projectListView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(appState.projects) { project in
                    ProjectRowView(project: project, launcher: launcher)
                        .background(Color(NSColor.controlBackgroundColor))
                }
            }
        }
        .frame(maxHeight: 300)
    }
    
    @ViewBuilder
    private var footerView: some View {
        HStack {
            Button("Settings") {
                openSettings()
            }
            .buttonStyle(.borderless)
            .font(.caption)
            
            Button("Reload Config") {
                appState.reloadConfig()
            }
            .buttonStyle(.borderless)
            .font(.caption)
            
            Spacer()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .font(.caption)
            .foregroundColor(.red)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func openSettings() {
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        settingsWindow.title = "topDoor Settings"
        settingsWindow.contentView = NSHostingView(
            rootView: SettingsView()
                .environmentObject(appState)
        )
        settingsWindow.center()
        settingsWindow.makeKeyAndOrderFront(nil)
        
        // ウィンドウを前面に表示
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func loadConfigIfNeeded() {
        if appState.projects.isEmpty && !appState.isLoading {
            appState.loadConfig()
        }
    }
}

struct ProjectRowView: View {
    let project: Project
    let launcher: ProjectLauncher
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("\(project.items.count) item\(project.items.count == 1 ? "" : "s")")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Open All") {
                launcher.openAllItems(in: project)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .tint(.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isHovered ? Color(NSColor.selectedControlColor).opacity(0.3) : Color.clear)
        .cornerRadius(6)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            launcher.openAllItems(in: project)
        }
        .help("Click to open all items in \(project.name)")
    }
}

#Preview {
    MenuBarContentView()
        .environmentObject({
            let state = AppState()
            state.projects = [
                Project(id: "sample1", name: "Sample Project 1", 
                       items: ["https://github.com", "file:///Applications"]),
                Project(id: "sample2", name: "Sample Project 2", 
                       items: ["https://apple.com"]),
                Project(id: "sample3", name: "Long Project Name That Might Wrap", 
                       items: ["https://example.com", "file:///Users", "https://stackoverflow.com"])
            ]
            return state
        }())
        .frame(width: 300, height: 400)
}
