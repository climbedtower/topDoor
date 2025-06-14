import SwiftUI

@main
struct MenuLinkerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // メニューバーアイテムを作成
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "link", accessibilityDescription: "Links")
        }
        
        // 仮のメニューを作成
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Google", action: #selector(openGoogle), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Apple", action: #selector(openApple), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func openGoogle() {
        if let url = URL(string: "https://www.google.com") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc func openApple() {
        if let url = URL(string: "https://www.apple.com") {
        NSWorkspace.shared.open(url)
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
