//
//  Models.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import Foundation
import SwiftUI

// MARK: - Data Models
struct Project: Identifiable, Codable {
    let id: String
    let name: String
    let items: [String]
    let scrapboxPage: String? // Scrapbox ページ URL（オプション）
    
    init(id: String, name: String, items: [String], scrapboxPage: String? = nil) {
        self.id = id
        self.name = name
        self.items = items
        self.scrapboxPage = scrapboxPage
    }
}

struct Configuration: Codable {
    let projects: [Project]
    let scrapboxPageURL: String? // 設定管理用の Scrapbox ページ URL
    let scrapboxPageName: String? // Scrapboxページ名
    let scrapboxProjectName: String? // Scrapboxプロジェクト名
    
    init(projects: [Project] = [], 
         scrapboxPageURL: String? = nil,
         scrapboxPageName: String? = nil,
         scrapboxProjectName: String? = nil) {
        self.projects = projects
        self.scrapboxPageURL = scrapboxPageURL
        self.scrapboxPageName = scrapboxPageName
        self.scrapboxProjectName = scrapboxProjectName
    }
}

// MARK: - AppState
@MainActor
class AppState: ObservableObject {
    @Published var projects: [Project] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private(set) var currentConfig: Configuration?
    private var configLoader: ConfigLoader?
    
    init() {
        do {
            self.configLoader = try ConfigLoader()
            loadConfig()
        } catch {
            print("❌ Failed to initialize ConfigLoader: \(error)")
            self.errorMessage = "Failed to initialize configuration loader"
        }
    }
    
    func loadConfig() {
        guard let configLoader = self.configLoader else {
            print("❌ ConfigLoader not available")
            self.errorMessage = "Configuration loader not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let config = try configLoader.loadConfiguration()
                await MainActor.run {
                    self.currentConfig = config
                    self.projects = config.projects
                    self.isLoading = false
                }
                print("✅ Configuration loaded: \(config.projects.count) projects")
            } catch {
                await MainActor.run {
                    self.projects = []
                    self.isLoading = false
                    self.errorMessage = "Failed to load configuration: \(error.localizedDescription)"
                }
                print("❌ Failed to load configuration: \(error)")
            }
        }
    }
    
    func reloadConfig() {
        print("🔄 Reloading configuration...")
        loadConfig()
    }
    
    func updateScrapboxURL(_ url: String) {
        let newConfig = Configuration(
            projects: currentConfig?.projects ?? [],
            scrapboxPageURL: url
        )
        saveConfiguration(newConfig)
    }
    
    func fetchFromScrapbox() async throws {
        guard let config = currentConfig,
              let scrapboxURL = config.scrapboxPageURL else {
            throw AppError.noScrapboxURL
        }
        
        // Scrapbox URLの有効性をチェック
        guard ScrapboxService.isValidScrapboxURL(scrapboxURL) else {
            throw AppError.scrapboxFetchFailed("Invalid Scrapbox URL format")
        }
        
        // Scrapboxからページ内容を取得
        let pageContent = try await ScrapboxService.fetchPageContent(from: scrapboxURL)
        
        // ページ名をグループ名として使用した設定を作成
        let newConfig = Configuration(
            projects: pageContent.projects,
            scrapboxPageURL: scrapboxURL,
            scrapboxPageName: pageContent.pageName,
            scrapboxProjectName: pageContent.projectName
        )
        
        await MainActor.run {
            saveConfiguration(newConfig)
            self.projects = pageContent.projects
        }
    }
    
    func resetToDefaults() {
        let defaultConfig = Configuration()
        saveConfiguration(defaultConfig)
        currentConfig = defaultConfig
        projects = []
    }
    
    private func saveConfiguration(_ config: Configuration) {
        guard let configLoader = self.configLoader else {
            errorMessage = "Configuration loader not available"
            print("❌ ConfigLoader not available for saving")
            return
        }
        
        do {
            try configLoader.saveConfiguration(config)
            currentConfig = config
            print("✅ Configuration saved")
        } catch {
            errorMessage = "Failed to save configuration: \(error.localizedDescription)"
            print("❌ Failed to save configuration: \(error)")
        }
    }
}

enum AppError: Error, LocalizedError {
    case noScrapboxURL
    case scrapboxFetchFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .noScrapboxURL:
            return "No Scrapbox URL configured"
        case .scrapboxFetchFailed(let message):
            return "Failed to fetch from Scrapbox: \(message)"
        }
    }
}
