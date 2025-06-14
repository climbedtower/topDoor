//
//  ErrorAlert.swift
//  topDoor
//
//  Created by yuco on 2025/06/15.
//

import AppKit
import Foundation

struct ErrorAlert {
    static func show(title: String, message: String, style: NSAlert.Style = .critical) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = message
            alert.alertStyle = style
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    static func showOpenError(for item: String, error: Error) {
        let title = "Failed to Open Item"
        let message = "Could not open '\(item)'\n\nError: \(error.localizedDescription)"
        show(title: title, message: message, style: .warning)
    }
}
