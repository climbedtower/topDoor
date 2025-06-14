import Foundation

// リンクの種類
enum LinkType: String, CaseIterable, Codable {
    case web = "web"
    case app = "app"
    case file = "file"
    
    var displayName: String {
        switch self {
        case .web: return "ウェブサイト"
        case .app: return "アプリケーション"
        case .file: return "ファイル/フォルダ"
        }
    }
}

// リンクデータモデル
struct LinkItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var url: String
    var type: LinkType
    var openWith: String? // ファイルを開くアプリを指定する場合
    
    init(name: String, url: String, type: LinkType, openWith: String? = nil) {
        self.name = name
        self.url = url
        self.type = type
        self.openWith = openWith
    }
}

// リンク管理クラス
class LinkManager: ObservableObject {
    @Published var links: [LinkItem] = []
    
    private let userDefaults = UserDefaults.standard
    private let linksKey = "SavedLinks"
    
    init() {
        loadLinks()
    }
    
    // リンクをUserDefaultsから読み込み
    func loadLinks() {
        if let data = userDefaults.data(forKey: linksKey),
           let decodedLinks = try? JSONDecoder().decode([LinkItem].self, from: data) {
            self.links = decodedLinks
        } else {
            // 初期データ
            self.links = [
                LinkItem(name: "Google", url: "https://www.google.com", type: .web),
                LinkItem(name: "Apple", url: "https://www.apple.com", type: .web)
            ]
        }
    }
    
    // リンクをUserDefaultsに保存
    func saveLinks() {
        if let encodedData = try? JSONEncoder().encode(links) {
            userDefaults.set(encodedData, forKey: linksKey)
        }
    }
    
    // リンクを追加
    func addLink(_ link: LinkItem) {
        links.append(link)
        saveLinks()
    }
    
    // リンクを削除
    func removeLink(_ link: LinkItem) {
        links.removeAll { $0.id == link.id }
        saveLinks()
    }
    
    // リンクを移動
    func moveLink(from: IndexSet, to: Int) {
        links.move(fromOffsets: from, toOffset: to)
        saveLinks()
    }
    
    // リンクを開く
    func openLink(_ link: LinkItem) {
        switch link.type {
        case .web:
            if let url = URL(string: link.url) {
                NSWorkspace.shared.open(url)
            }
        case .app:
            let url = URL(fileURLWithPath: link.url)
            NSWorkspace.shared.open(url)
        case .file:
            if let openWith = link.openWith, !openWith.isEmpty {
                NSWorkspace.shared.openFile(link.url, withApplication: openWith)
            } else {
                let url = URL(fileURLWithPath: link.url)
                NSWorkspace.shared.open(url)
            }
        }
    }
}
