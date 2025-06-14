//
//  Models.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import Foundation

// MARK: - Configuration Models

struct Config: Codable {
    let projects: [Project]
    
    static let empty = Config(projects: [])
}

struct Project: Codable, Identifiable {
    let id: String
    let name: String
    let items: [String]
}

// MARK: - App State

@MainActor
class AppState: ObservableObject {
    @Published var projects: [Project] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var configLoader: ConfigLoader?
    
    init() {
        print("AppState initialized")
        do {
            self.configLoader = try ConfigLoader()
        } catch {
            print("Failed to initialize ConfigLoader: \(error)")
            self.errorMessage = "Failed to initialize configuration loader"
        }
    }
    
    func loadConfig() {
        print("Loading config...")
        guard let configLoader = self.configLoader else {
            print("ConfigLoader not available")
            self.errorMessage = "Configuration loader not available"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let config = try await configLoader.loadConfig()
                await MainActor.run {
                    print("Config loaded with \(config.projects.count) projects")
                    self.projects = config.projects
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    print("Failed to load config: \(error)")
                    self.errorMessage = error.localizedDescription
                    self.projects = []
                    self.isLoading = false
                }
            }
        }
    }
    
    func reloadConfig() {
        print("Reloading config...")
        loadConfig()
    }
}
