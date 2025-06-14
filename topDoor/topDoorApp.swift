import SwiftUI
import Combine

@main
struct TopDoorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var linkManager = LinkManager()
    var linksSubscriber: AnyCancellable?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // メニューバーアイテムを作成
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "link", accessibilityDescription: "Links")
        }

        buildMenu()

        // リンク変更を監視し、メニューを更新
        linksSubscriber = linkManager.$links.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.buildMenu()
            }
        }
    }

    func buildMenu() {
        let menu = NSMenu()

        // 動的にリンクメニューを生成
        for link in linkManager.links {
            let item = NSMenuItem(title: link.name, action: #selector(openLinkItem(_:)), keyEquivalent: "")
            item.representedObject = link
            item.target = self
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func openLinkItem(_ sender: NSMenuItem) {
        if let link = sender.representedObject as? LinkItem {
            linkManager.openLink(link)
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
