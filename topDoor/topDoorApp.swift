import SwiftUI
import Combine
import AppKit

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
    var editWindow: NSWindow?
    
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

        let editItem = NSMenuItem(title: "リンクを編集...", action: #selector(openManageLinks), keyEquivalent: "")
        editItem.target = self
        menu.addItem(editItem)

        menu.addItem(NSMenuItem(title: "Version \(AppVersion.current)", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func openLinkItem(_ sender: NSMenuItem) {
        if let link = sender.representedObject as? LinkItem {
            linkManager.openLink(link)
        }
    }

    @objc func openManageLinks() {
        if editWindow == nil {
            let editView = LinkEditView(linkManager: linkManager)
            let controller = NSHostingController(rootView: editView)
            editWindow = NSWindow(contentViewController: controller)
            editWindow?.title = "リンク編集"
            editWindow?.setContentSize(NSSize(width: 500, height: 400))
            NotificationCenter.default.addObserver(self, selector: #selector(editWindowClosed(_:)), name: NSWindow.willCloseNotification, object: editWindow)
        }
        editWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func editWindowClosed(_ notification: Notification) {
        if let win = notification.object as? NSWindow, win == editWindow {
            editWindow = nil
        }
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
