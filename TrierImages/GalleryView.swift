import SwiftUI

struct GalleryView: View {
    @ObservedObject var store: ImageStore
    @Binding var selection: Set<ImageItem>
    @Binding var detailImage: ImageItem?
    var isDropTargeted: Bool

    @AppStorage("thumbnailSize") private var thumbnailSize: Double = 160
    @State private var lastClickedItem: ImageItem?

    private let minThumbSize: CGFloat = 80
    private let maxThumbSize: CGFloat = 400

    var body: some View {
        ZStack {
            if store.images.isEmpty && !store.isLoading {
                emptyState
            } else if store.isLoading {
                loadingState
            } else {
                galleryGrid
            }

            // Drop target overlay
            if isDropTargeted {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.accentColor, style: StrokeStyle(lineWidth: 3, dash: [8, 4]))
                    .background(Color.accentColor.opacity(0.08))
                    .padding(8)
                    .allowsHitTesting(false)
            }
        }
        .background(backgroundTapArea)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundColor(.secondary.opacity(0.5))
            Text("Ouvrir un dossier pour commencer")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Fichier > Ouvrir un dossier  ou  \u{2318}O")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.6))
            Text("ou glisser un dossier ici")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.4))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.5)
            if store.loadingCount > 0 {
                Text("\(store.loadingCount) images trouvées...")
                    .foregroundColor(.secondary)
            } else {
                Text("Chargement des images...")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var galleryGrid: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: thumbnailSize, maximum: thumbnailSize), spacing: 8)],
                    spacing: 8
                ) {
                    ForEach(store.images) { item in
                        ThumbnailView(item: item, isSelected: selection.contains(item), size: thumbnailSize)
                            .overlay {
                                ClickableView(
                                    onClick: { event in
                                        handleClick(item: item, event: event)
                                    },
                                    onDoubleClick: {
                                        detailImage = item
                                    }
                                )
                            }
                            .contextMenu {
                                Button("Voir en grand") {
                                    detailImage = item
                                }
                                Divider()
                                Button("Copier l'image") {
                                    if let image = NSImage(contentsOf: item.url) {
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.writeObjects([image])
                                    }
                                }
                                Button("Copier le chemin") {
                                    let paths = selection.contains(item)
                                        ? selection.map { $0.url.path(percentEncoded: false) }
                                        : [item.url.path(percentEncoded: false)]
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(paths.joined(separator: "\n"), forType: .string)
                                }
                                Button("Afficher dans le Finder") {
                                    let urls = selection.contains(item) ? selection.map(\.url) : [item.url]
                                    NSWorkspace.shared.activateFileViewerSelecting(urls)
                                }
                                Divider()
                                Button("Mettre à la corbeille", role: .destructive) {
                                    let toTrash = selection.contains(item) ? selection : Set([item])
                                    store.trashImages(toTrash)
                                    selection.removeAll()
                                }
                            }
                    }
                }
                .padding(12)
            }

            Divider()

            // Size slider bar
            sizeSlider
        }
    }

    private var sizeSlider: some View {
        HStack(spacing: 8) {
            Spacer()
            Image(systemName: "photo")
                .font(.caption2)
                .foregroundColor(.secondary)
            Slider(value: $thumbnailSize, in: minThumbSize...maxThumbSize, step: 20)
                .frame(width: 120)
            Image(systemName: "photo")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .frame(height: 24)
        .background(.bar)
    }

    private var backgroundTapArea: some View {
        Color.clear
            .contentShape(Rectangle())
            .onTapGesture {
                selection.removeAll()
            }
    }

    private func handleClick(item: ImageItem, event: NSEvent?) {
        let shiftHeld = event?.modifierFlags.contains(.shift) ?? false
        let cmdHeld = event?.modifierFlags.contains(.command) ?? false

        if cmdHeld {
            if selection.contains(item) {
                selection.remove(item)
            } else {
                selection.insert(item)
            }
            lastClickedItem = item
        } else if shiftHeld, let last = lastClickedItem,
                  let lastIdx = store.images.firstIndex(of: last),
                  let currentIdx = store.images.firstIndex(of: item) {
            let range = min(lastIdx, currentIdx)...max(lastIdx, currentIdx)
            for i in range {
                selection.insert(store.images[i])
            }
        } else {
            selection = Set([item])
            lastClickedItem = item
        }
    }
}

// MARK: - ClickableView (NSViewRepresentable for instant click handling)

struct ClickableView: NSViewRepresentable {
    var onClick: (NSEvent) -> Void
    var onDoubleClick: () -> Void

    func makeNSView(context: Context) -> ClickableNSView {
        let view = ClickableNSView()
        view.onClick = onClick
        view.onDoubleClick = onDoubleClick
        return view
    }

    func updateNSView(_ nsView: ClickableNSView, context: Context) {
        nsView.onClick = onClick
        nsView.onDoubleClick = onDoubleClick
    }
}

class ClickableNSView: NSView {
    var onClick: ((NSEvent) -> Void)?
    var onDoubleClick: (() -> Void)?

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func mouseDown(with event: NSEvent) {
        if event.clickCount == 2 {
            onDoubleClick?()
        } else {
            onClick?(event)
        }
    }
}
