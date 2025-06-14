//
//  ProjectLauncher.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import AppKit
import Foundation
import OSLog

class ProjectLauncher {
    private let logger = Logger(subsystem: "com.yuco.topDoor", category: "ProjectLauncher")
    
    func openAllItems(in project: Project) {
        logger.info("Opening all items for project: \(project.name)")
        
        for item in project.items {
            openItem(item)
        }
    }
    
    private func openItem(_ item: String) {
        logger.info("Attempting to open: \(item)")
        
        // Create URL from string
        let url: URL
        
        if item.hasPrefix("file://") {
            if let fileURL = URL(string: item) {
                url = fileURL
            } else {
                // Fallback to file path
                let path = item.replacingOccurrences(of: "file://", with: "")
                url = URL(fileURLWithPath: path)
            }
        } else if item.hasPrefix("http://") || item.hasPrefix("https://") {
            guard let webURL = URL(string: item) else {
                logger.error("Invalid URL format: \(item)")
                ErrorAlert.show(title: "Invalid URL", message: "Could not parse URL: \(item)")
                return
            }
            url = webURL
        } else {
            // Treat as file path
            url = URL(fileURLWithPath: item)
        }
        
        // Open the URL
        DispatchQueue.main.async {
            let success = NSWorkspace.shared.open(url)
            if !success {
                self.logger.error("Failed to open \(item): NSWorkspace returned false")
                ErrorAlert.show(title: "Failed to Open", 
                              message: "Could not open '\(item)'. The item may not exist or may not be associated with any application.")
            } else {
                self.logger.info("Successfully opened: \(item)")
            }
        }
    }
}
