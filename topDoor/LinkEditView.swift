import SwiftUI

struct LinkEditView: View {
    @ObservedObject var linkManager: LinkManager
    @State private var newName = ""
    @State private var newURL = ""
    @State private var newType: LinkType = .web

    var body: some View {
        VStack {
            List {
                ForEach(linkManager.links) { link in
                    VStack(alignment: .leading) {
                        Text(link.name).font(.headline)
                        Text(link.url).font(.caption)
                    }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            HStack {
                TextField("名前", text: $newName)
                TextField("URL", text: $newURL)
                Picker("種類", selection: $newType) {
                    ForEach(LinkType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                Button("追加") {
                    addNewLink()
                }
                .disabled(newName.isEmpty || newURL.isEmpty)
            }
            .padding()
        }
        .frame(minWidth: 400, minHeight: 300)
        .toolbar { EditButton() }
    }

    private func addNewLink() {
        let item = LinkItem(name: newName, url: newURL, type: newType)
        linkManager.addLink(item)
        newName = ""
        newURL = ""
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { linkManager.links[$0] }.forEach(linkManager.removeLink)
    }

    private func move(from source: IndexSet, to destination: Int) {
        linkManager.moveLink(from: source, to: destination)
    }
}

#Preview {
    LinkEditView(linkManager: LinkManager())
}
