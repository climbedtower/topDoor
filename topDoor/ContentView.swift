import SwiftUI

struct ContentView: View {
    @StateObject private var linkManager = LinkManager()
    @State private var newName: String = ""
    @State private var newURL: String = ""
    @State private var newType: LinkType = .web

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach($linkManager.links) { $link in
                        VStack(alignment: .leading) {
                            TextField("名前", text: $link.name)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: link.name) { _ in
                                    linkManager.saveLinks()
                                }
                            TextField("URL", text: $link.url)
                                .textFieldStyle(.roundedBorder)
                                .onChange(of: link.url) { _ in
                                    linkManager.saveLinks()
                                }
                            Picker("種類", selection: $link.type) {
                                ForEach(LinkType.allCases, id: .self) { type in
                                    Text(type.displayName).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                            .onChange(of: link.type) { _ in
                                linkManager.saveLinks()
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        linkManager.links.remove(atOffsets: indexSet)
                        linkManager.saveLinks()
                    }
                    .onMove { indices, newOffset in
                        linkManager.links.move(fromOffsets: indices, toOffset: newOffset)
                        linkManager.saveLinks()
                    }
                }

                HStack {
                    TextField("名前", text: $newName)
                        .textFieldStyle(.roundedBorder)
                    TextField("URL", text: $newURL)
                        .textFieldStyle(.roundedBorder)
                    Picker("種類", selection: $newType) {
                        ForEach(LinkType.allCases, id: .self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    Button("追加") {
                        guard !newName.isEmpty, !newURL.isEmpty else { return }
                        let link = LinkItem(name: newName, url: newURL, type: newType)
                        linkManager.links.append(link)
                        linkManager.saveLinks()
                        newName = ""
                        newURL = ""
                        newType = .web
                    }
                }
                .padding()
            }
            .navigationTitle("リンク一覧")
            .toolbar { EditButton() }
        }
    }
}

#Preview {
    ContentView()
}
