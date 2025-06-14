//
//  ConfigLoader.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import Foundation

class ConfigLoader {
    private let configPath: URL
    private let backupPath: URL
    
    init() throws {
        guard let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, 
                                                          in: .userDomainMask).first else {
            throw NSError(domain: "ConfigLoader", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to access Application Support directory"])
        }
        
        let devLauncherDir = appSupportURL.appendingPathComponent("DevLauncher")
        
        self.configPath = devLauncherDir.appendingPathComponent("config.json")
        self.backupPath = devLauncherDir.appendingPathComponent("config.json.bak")
        
        // Create directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(at: devLauncherDir, 
                                                   withIntermediateDirectories: true)
        } catch {
            print("Failed to create DevLauncher directory: \(error)")
            // Don't throw here, as the directory might already exist
        }
    }
    
    func loadConfig() async throws -> Config {
        // Check if config file exists
        guard FileManager.default.fileExists(atPath: configPath.path) else {
            // Create default config
            let defaultConfig = createDefaultConfig()
            try await saveConfig(defaultConfig)
            return defaultConfig
        }
        
        do {
            let data = try Data(contentsOf: configPath)
            let config = try JSONDecoder().decode(Config.self, from: data)
            return config
        } catch {
            // Try to restore from backup
            if FileManager.default.fileExists(atPath: backupPath.path) {
                do {
                    let backupData = try Data(contentsOf: backupPath)
                    let config = try JSONDecoder().decode(Config.self, from: backupData)
                    // Restore the main config from backup
                    try backupData.write(to: configPath)
                    return config
                } catch {
                    // Backup is also corrupted, create new default
                    let defaultConfig = createDefaultConfig()
                    try await saveConfig(defaultConfig)
                    return defaultConfig
                }
            } else {
                // No backup, create new default
                let defaultConfig = createDefaultConfig()
                try await saveConfig(defaultConfig)
                return defaultConfig
            }
        }
    }
    
    private func saveConfig(_ config: Config) async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(config)
        
        // Create backup if main config exists
        if FileManager.default.fileExists(atPath: configPath.path) {
            try? FileManager.default.copyItem(at: configPath, to: backupPath)
        }
        
        try data.write(to: configPath)
    }
    
    private func createDefaultConfig() -> Config {
        let sampleProject = Project(
            id: "sample",
            name: "Sample Project",
            items: [
                "https://github.com",
                "file:///Applications/Xcode.app"
            ]
        )
        
        return Config(projects: [sampleProject])
    }
    
    var configFileURL: URL {
        return configPath
    }
}
