//
//  ConfigLoader.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import Foundation

class ConfigLoader {
    static let configDirectory: URL = {
        guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access Application Support directory")
        }
        return appSupport.appendingPathComponent("topDoor")
    }()
    
    private let configURL: URL
    private let backupURL: URL
    
    init() throws {
        self.configURL = Self.configDirectory.appendingPathComponent("config.json")
        self.backupURL = Self.configDirectory.appendingPathComponent("config.json.bak")
        try ensureConfigDirectoryExists()
    }
    
    func loadConfiguration() throws -> Configuration {
        // 設定ディレクトリとファイルの存在確認
        if !FileManager.default.fileExists(atPath: configURL.path) {
            print("📝 Config file doesn't exist, creating default configuration")
            let defaultConfig = createDefaultConfiguration()
            try saveConfiguration(defaultConfig)
            return defaultConfig
        }
        
        do {
            let data = try Data(contentsOf: configURL)
            let config = try JSONDecoder().decode(Configuration.self, from: data)
            print("✅ Configuration loaded from: \(configURL.path)")
            return config
        } catch {
            print("⚠️ Failed to load config, attempting backup...")
            return try loadBackupConfiguration()
        }
    }
    
    func saveConfiguration(_ config: Configuration) throws {
        // 既存の設定をバックアップ
        if FileManager.default.fileExists(atPath: configURL.path) {
            try? FileManager.default.copyItem(at: configURL, to: backupURL)
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(config)
        try data.write(to: configURL)
        
        print("✅ Configuration saved to: \(configURL.path)")
    }
    
    private func loadBackupConfiguration() throws -> Configuration {
        if FileManager.default.fileExists(atPath: backupURL.path) {
            let data = try Data(contentsOf: backupURL)
            let config = try JSONDecoder().decode(Configuration.self, from: data)
            print("✅ Configuration loaded from backup")
            return config
        } else {
            print("📝 No backup found, creating default configuration")
            return createDefaultConfiguration()
        }
    }
    
    private func createDefaultConfiguration() -> Configuration {
        return Configuration(
            projects: [
                Project(
                    id: "example",
                    name: "Example Project",
                    items: [
                        "https://github.com",
                        "file:///Applications"
                    ]
                )
            ],
            scrapboxPageURL: nil
        )
    }
    
    private func ensureConfigDirectoryExists() throws {
        if !FileManager.default.fileExists(atPath: Self.configDirectory.path) {
            try FileManager.default.createDirectory(at: Self.configDirectory, withIntermediateDirectories: true)
            print("📁 Created config directory: \(Self.configDirectory.path)")
        }
    }
}
