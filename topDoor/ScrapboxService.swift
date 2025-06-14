//
//  ScrapboxService.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import Foundation

struct ScrapboxService {
    
    /// Scrapbox URLからページ名を抽出
    static func extractPageName(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url) else { return nil }
        
        // Scrapbox URLの形式: https://scrapbox.io/project-name/page-name
        let pathComponents = urlComponents.path.components(separatedBy: "/")
        
        // パスが /project-name/page-name の形式かチェック
        if pathComponents.count >= 3 {
            let pageName = pathComponents[2]
            // URLエンコードされた文字をデコードして、より読みやすい形にする
            let decodedName = pageName.removingPercentEncoding ?? pageName
            // アンダースコアをスペースに変換
            return decodedName.replacingOccurrences(of: "_", with: " ")
        }
        
        return nil
    }
    
    /// Scrapbox URLからプロジェクト名を抽出
    static func extractProjectName(from url: String) -> String? {
        guard let urlComponents = URLComponents(string: url) else { return nil }
        
        let pathComponents = urlComponents.path.components(separatedBy: "/")
        
        if pathComponents.count >= 2 {
            let projectName = pathComponents[1]
            return projectName.removingPercentEncoding ?? projectName
        }
        
        return nil
    }
    
    /// Scrapbox URLが有効かどうかをチェック
    static func isValidScrapboxURL(_ url: String) -> Bool {
        guard let urlComponents = URLComponents(string: url),
              let host = urlComponents.host else { return false }
        
        return host == "scrapbox.io" && urlComponents.path.components(separatedBy: "/").count >= 3
    }
    
    /// Scrapbox APIからページ内容を取得（将来的な実装用）
    static func fetchPageContent(from url: String) async throws -> ScrapboxPageContent {
        // 現在はモックデータを返す
        // 実際の実装では Scrapbox API を呼び出す
        
        guard let pageName = extractPageName(from: url),
              let projectName = extractProjectName(from: url) else {
            throw ScrapboxError.invalidURL
        }
        
        // ページ名を使用したIDの生成
        let cleanPageName = pageName.lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "　", with: "-")
        
        // モックプロジェクトデータ - ページ名をプロジェクト名として使用
        let mockProjects = [
            Project(
                id: "\(cleanPageName)-main",
                name: pageName,
                items: [
                    "file:///Applications/Xcode.app",
                    "file:///Applications/Visual Studio Code.app",
                    "https://github.com/climbedtower/topDoor",
                    "https://docs.swift.org"
                ],
                scrapboxPage: url
            ),
            Project(
                id: "\(cleanPageName)-tools",
                name: "\(pageName) - ツール",
                items: [
                    "https://figma.com",
                    "file:///Applications/Dash.app",
                    "https://developer.apple.com/documentation/"
                ],
                scrapboxPage: url
            )
        ]
        
        return ScrapboxPageContent(
            pageName: pageName,
            projectName: projectName,
            projects: mockProjects
        )
    }
}

struct ScrapboxPageContent {
    let pageName: String
    let projectName: String
    let projects: [Project]
}

enum ScrapboxError: Error, LocalizedError {
    case invalidURL
    case networkError(String)
    case parseError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Scrapbox URL format"
        case .networkError(let message):
            return "Network error: \(message)"
        case .parseError(let message):
            return "Parse error: \(message)"
        }
    }
}
