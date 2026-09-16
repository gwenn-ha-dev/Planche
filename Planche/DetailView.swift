import SwiftUI

struct DetailView: View {
    @ObservedObject var store: ImageStore
    @Binding var currentImage: ImageItem?

    @State private var currentIndex: Int = 0
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let item = currentItem {
                FullImageView(url: item.url)
                    .id(item.id)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            }

            // Navigation overlay
            HStack {
                // Left arrow zone
                Color.clear
                    .frame(width: 60)
                    .contentShape(Rectangle())
                    .onTapGesture { navigatePrevious() }
                    .overlay(alignment: .center) {
                        if currentIndex > 0 {
                            Image(systemName: "chevron.left")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.7))
                                .shadow(radius: 4)
                        }
                    }

                Spacer()

                // Right arrow zone
                Color.clear
                    .frame(width: 60)
                    .contentShape(Rectangle())
                    .onTapGesture { navigateNext() }
                    .overlay(alignment: .center) {
                        if currentIndex < store.images.count - 1 {
                            Image(systemName: "chevron.right")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.7))
                                .shadow(radius: 4)
                        }
                    }
            }

            // Top bar
            VStack {
                HStack {
                    Button(action: { currentImage = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .padding(12)

                    Button(action: { trashCurrent() }) {
                        Image(systemName: "trash")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .help("Mettre à la corbeille")

                    Button(action: {
                        if let item = currentItem {
                            NSWorkspace.shared.activateFileViewerSelecting([item.url])
                        }
                    }) {
                        Image(systemName: "folder")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .help("Afficher dans le Finder")

                    Button(action: {
                        if let item = currentItem, let image = NSImage(contentsOf: item.url) {
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.writeObjects([image])
                        }
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                    .help("Copier l'image")

                    Spacer()

                    if let item = currentItem {
                        Text(relativePath(for: item))
                            .foregroundColor(.white.opacity(0.8))
                            .font(.callout)
                            .lineLimit(1)
                            .truncationMode(.head)
                    }

                    Spacer()

                    Text("\(currentIndex + 1) / \(store.images.count)")
                        .foregroundColor(.white.opacity(0.6))
                        .font(.callout)
                        .padding(.trailing, 12)
                }
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.6), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                    .allowsHitTesting(false)
                )

                Spacer()
            }
        }
        .focusable()
        .focused($isFocused)
        .onAppear {
            syncIndex()
            isFocused = true
        }
        .onChange(of: currentImage) { syncIndex() }
        .onKeyPress(.leftArrow) { navigatePrevious(); return .handled }
        .onKeyPress(.rightArrow) { navigateNext(); return .handled }
        .onKeyPress(.escape) { currentImage = nil; return .handled }
        .onKeyPress(.space) { currentImage = nil; return .handled }
        .onKeyPress(.delete) { trashCurrent(); return .handled }
        .onKeyPress(KeyEquivalent.init(Character(UnicodeScalar(NSDeleteCharacter)!))) {
            trashCurrent(); return .handled
        }
    }

    private func relativePath(for item: ImageItem) -> String {
        guard let folder = store.folderURL else { return item.filename }
        let folderPath = folder.path(percentEncoded: false)
        let filePath = item.url.path(percentEncoded: false)
        if filePath.hasPrefix(folderPath) {
            let relative = String(filePath.dropFirst(folderPath.count))
            return relative.hasPrefix("/") ? String(relative.dropFirst()) : relative
        }
        return item.filename
    }

    private var currentItem: ImageItem? {
        guard currentIndex >= 0 && currentIndex < store.images.count else { return nil }
        return store.images[currentIndex]
    }

    private func syncIndex() {
        if let img = currentImage, let idx = store.images.firstIndex(of: img) {
            currentIndex = idx
        }
    }

    private func navigatePrevious() {
        guard currentIndex > 0 else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            currentIndex -= 1
            currentImage = store.images[currentIndex]
        }
    }

    private func navigateNext() {
        guard currentIndex < store.images.count - 1 else { return }
        withAnimation(.easeInOut(duration: 0.15)) {
            currentIndex += 1
            currentImage = store.images[currentIndex]
        }
    }

    private func trashCurrent() {
        guard let item = currentItem else { return }
        let nextIndex = min(currentIndex, store.images.count - 2)
        store.trashImage(item)

        if store.images.isEmpty {
            currentImage = nil
        } else {
            currentIndex = max(0, min(nextIndex, store.images.count - 1))
            currentImage = store.images[currentIndex]
        }
    }
}
