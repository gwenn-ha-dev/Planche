import SwiftUI

struct ContentView: View {
    @StateObject private var store = ImageStore()
    @State private var selection = Set<ImageItem>()
    @State private var detailImage: ImageItem?
    @State private var showDeleteConfirm = false
    @State private var showShortcuts = false
    @State private var isDropTargeted = false
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            mainContent
                .opacity(detailImage == nil ? 1 : 0)

            if detailImage != nil {
                DetailView(store: store, currentImage: $detailImage)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: detailImage != nil)
        .frame(minWidth: 600, minHeight: 400)
        .focusable()
        .focusEffectDisabled()
        .focused($isFocused)
        .onChange(of: detailImage) {
            if detailImage == nil {
                isFocused = true
            }
        }
        .onKeyPress(.delete) {
            guard detailImage == nil else { return .ignored }
            return handleDelete()
        }
        .onKeyPress(KeyEquivalent(Character(UnicodeScalar(NSDeleteCharacter)!))) {
            guard detailImage == nil else { return .ignored }
            return handleDelete()
        }
        .onKeyPress(.space) {
            guard detailImage == nil else { return .ignored }
            if let first = selection.first {
                detailImage = first
                return .handled
            }
            return .ignored
        }
        .onKeyPress(keys: [KeyEquivalent("a")], phases: .down) { _ in
            guard NSEvent.modifierFlags.contains(.command) else { return .ignored }
            if detailImage == nil {
                selection = Set(store.images)
                return .handled
            }
            return .ignored
        }
        .alert("Supprimer \(selection.count) images ?",
               isPresented: $showDeleteConfirm) {
            Button("Mettre à la corbeille", role: .destructive) {
                store.trashImages(selection)
                selection.removeAll()
            }
            Button("Annuler", role: .cancel) {}
        } message: {
            Text("Les images seront déplacées dans la corbeille du Mac.")
        }
        .alert("Erreur", isPresented: Binding(
            get: { store.lastError != nil },
            set: { if !$0 { store.lastError = nil } }
        )) {
            Button("OK") {}
        } message: {
            Text(store.lastError ?? "")
        }
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers)
        }
        .onChange(of: store.folderURL) {
            selection.removeAll()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openFolder)) { _ in
            store.openFolder()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showShortcuts)) { _ in
            showShortcuts = true
        }
        .sheet(isPresented: $showShortcuts) {
            ShortcutsView()
        }
        .task { applyLaunchArguments() }
        .onChange(of: store.images) { applyLaunchSelection() }
    }

    // MARK: - Launch arguments
    //
    // The README captures (outils/captures.sh) cannot click: they set the view
    // at launch. Only the argument domain is read — `-folder ~/x` on the command
    // line — so nothing here is ever persisted or read back from a past session.
    //   -folder <path>      open this folder
    //   -select <a,b,…>     then select these files
    //   -show <file>        then open this file in the detail view
    //   -shortcuts YES      show the keyboard shortcuts

    private var launchArguments: [String: Any] {
        UserDefaults.standard.volatileDomain(forName: UserDefaults.argumentDomain)
    }

    private func applyLaunchArguments() {
        if let path = launchArguments["folder"] as? String {
            store.loadFolder(URL(fileURLWithPath: (path as NSString).expandingTildeInPath, isDirectory: true))
        }
        if (launchArguments["shortcuts"] as? String).map({ ["YES", "1", "true"].contains($0) }) == true {
            showShortcuts = true
        }
    }

    private func applyLaunchSelection() {
        guard launchArguments["folder"] != nil, !store.images.isEmpty, selection.isEmpty, detailImage == nil else { return }
        if let names = launchArguments["select"] as? String {
            let wanted = Set(names.split(separator: ",").map(String.init))
            selection = Set(store.images.filter { wanted.contains($0.filename) })
        }
        if let name = launchArguments["show"] as? String {
            detailImage = store.images.first { $0.filename == name }
        }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Gallery
            GalleryView(store: store, selection: $selection, detailImage: $detailImage, isDropTargeted: isDropTargeted)

            Divider()

            // Status bar
            statusBar
        }
        .navigationTitle(store.folderURL?.lastPathComponent ?? "Planche")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { store.openFolder() }) {
                    Label("Ouvrir un dossier", systemImage: "folder.badge.plus")
                }
                .help("Ouvrir un dossier (⌘O)")
            }

            ToolbarItem(placement: .primaryAction) {
                if !selection.isEmpty {
                    Button(action: { showDeleteConfirm = true }) {
                        Label("Supprimer", systemImage: "trash")
                    }
                    .help("Supprimer la sélection (⌫)")
                }
            }
        }
    }

    private var statusBar: some View {
        HStack(spacing: 12) {
            if !store.images.isEmpty {
                Text("\(store.images.count) images")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if !selection.isEmpty {
                Text("\(selection.count) sélectionnées")
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .frame(height: 24)
        .background(.bar)
    }

    private func handleDelete() -> KeyPress.Result {
        guard !selection.isEmpty else { return .ignored }
        showDeleteConfirm = true
        return .handled
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
                guard let data = item as? Data,
                      let url = URL(dataRepresentation: data, relativeTo: nil) else { return }

                var isDir: ObjCBool = false
                if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                    Task { @MainActor in
                        store.loadFolder(url)
                    }
                }
            }
        }
        return true
    }
}
