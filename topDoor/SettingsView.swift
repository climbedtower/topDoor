//
//  SettingsView.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var scrapboxURL: String = ""
    @State private var isLoading: Bool = false
    @State private var message: String = ""
    @State private var messageType: MessageType = .info
    @Environment(\.dismiss) private var dismiss
    
    enum MessageType {
        case info, success, error
        
        var color: Color {
            switch self {
            case .info: return .blue
            case .success: return .green
            case .error: return .red
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "gear")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("Settings")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding()
            
            Divider()
            
            // Scrapbox Configuration
            VStack(alignment: .leading, spacing: 12) {
                Text("Scrapbox Integration")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Enter your Scrapbox page URL to automatically sync projects:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                TextField("https://scrapbox.io/your-project/ProjectManagement", text: $scrapboxURL)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        fetchFromScrapbox()
                    }
                
                // Scrapbox情報の表示
                if let config = appState.currentConfig,
                   let pageURL = config.scrapboxPageURL,
                   let pageName = config.scrapboxPageName,
                   let projectName = config.scrapboxProjectName {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Image(systemName: "link.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                            Text("Connected to Scrapbox")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                        }
                        
                        Text("Project: \(projectName)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("Page: \(pageName)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
                
                HStack {
                    Button("Fetch Projects") {
                        fetchFromScrapbox()
                    }
                    .buttonStyle(.bordered)
                    .disabled(scrapboxURL.isEmpty || isLoading)
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                
                if !message.isEmpty {
                    Text(message)
                        .font(.caption)
                        .foregroundColor(messageType.color)
                        .padding(.top, 4)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            // Current Configuration
            currentConfigView
            
            Spacer()
            
            // Actions
            HStack {
                Button("Open Config Folder") {
                    openConfigFolder()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Button("Reset to Defaults") {
                    resetToDefaults()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.red)
            }
            .padding()
        }
        .frame(width: 450, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            loadCurrentSettings()
        }
    }
    
    @ViewBuilder
    private var currentConfigView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current Projects")
                .font(.subheadline)
                .fontWeight(.medium)
            
            if appState.projects.isEmpty {
                Text("No projects configured")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(appState.projects) { project in
                            HStack {
                                Text(project.name)
                                    .font(.caption)
                                Spacer()
                                Text("\(project.items.count) items")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                        }
                    }
                }
                .frame(maxHeight: 120)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(4)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func loadCurrentSettings() {
        // 現在の設定から Scrapbox URL を取得（設定ファイルから読み込み）
        if let config = appState.currentConfig,
           let scrapboxPageURL = config.scrapboxPageURL {
            scrapboxURL = scrapboxPageURL
        }
    }
    
    private func fetchFromScrapbox() {
        let trimmedURL = scrapboxURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedURL.isEmpty else {
            showMessage("Please enter a valid Scrapbox URL", type: .error)
            return
        }
        
        // Scrapbox URLの形式をチェック
        guard ScrapboxService.isValidScrapboxURL(trimmedURL) else {
            showMessage("Invalid Scrapbox URL format. Expected: https://scrapbox.io/project/page", type: .error)
            return
        }
        
        // ページ名とプロジェクト名を表示
        if let pageName = ScrapboxService.extractPageName(from: trimmedURL),
           let projectName = ScrapboxService.extractProjectName(from: trimmedURL) {
            showMessage("Connecting to '\(pageName)' in project '\(projectName)'...", type: .info)
        }
        
        isLoading = true
        
        Task {
            do {
                await MainActor.run {
                    // ScrapboxのURLを設定に保存
                    appState.updateScrapboxURL(trimmedURL)
                }
                
                // Scrapboxからプロジェクトを取得
                try await appState.fetchFromScrapbox()
                
                await MainActor.run {
                    isLoading = false
                    if let pageName = ScrapboxService.extractPageName(from: trimmedURL) {
                        showMessage("Successfully loaded projects from '\(pageName)'!", type: .success)
                    } else {
                        showMessage("Successfully fetched projects from Scrapbox!", type: .success)
                    }
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    showMessage("Failed to fetch from Scrapbox: \(error.localizedDescription)", type: .error)
                }
            }
        }
    }
    
    private func showMessage(_ text: String, type: MessageType) {
        message = text
        messageType = type
        
        // メッセージを5秒後に自動消去
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if message == text {
                message = ""
            }
        }
    }
    
    private func openConfigFolder() {
        let configDir = ConfigLoader.configDirectory
        NSWorkspace.shared.open(configDir)
    }
    
    private func resetToDefaults() {
        let alert = NSAlert()
        alert.messageText = "Reset Configuration"
        alert.informativeText = "This will reset all settings to defaults. Are you sure?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            appState.resetToDefaults()
            scrapboxURL = ""
            showMessage("Configuration reset to defaults", type: .info)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject({
            let state = AppState()
            // プレビュー用のモックデータを直接設定
            state.projects = [
                Project(id: "sample1", name: "Sample Project", items: ["https://github.com"])
            ]
            return state
        }())
}