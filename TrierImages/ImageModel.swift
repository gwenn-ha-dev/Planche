import SwiftUI

struct ImageItem: Identifiable, Hashable {
    let id: UUID
    let url: URL
    let filename: String

    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.filename = url.lastPathComponent
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        lhs.id == rhs.id
    }
}

@MainActor
class ImageStore: ObservableObject {
    @Published var images: [ImageItem] = []
    @Published var folderURL: URL?
    @Published var isLoading = false
    @Published var loadingCount = 0
    @Published var lastError: String?

    private static let supportedExtensions: Set<String> = [
        "jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif",
        "heic", "heif", "webp", "avif", "svg"
    ]

    func openFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = String(localized: "Choisissez un dossier contenant des images")
        panel.prompt = String(localized: "Ouvrir")

        guard panel.runModal() == .OK, let url = panel.url else { return }
        loadFolder(url)
    }

    func loadFolder(_ url: URL) {
        folderURL = url
        isLoading = true
        images = []
        loadingCount = 0

        Task {
            let found = await scanImagesAsync(in: url)
            self.images = found
            self.isLoading = false
        }
    }

    private func scanImagesAsync(in folder: URL) async -> [ImageItem] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: folder,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return [] }

        var items: [ImageItem] = []
        for case let fileURL as URL in enumerator {
            if Self.supportedExtensions.contains(fileURL.pathExtension.lowercased()) {
                items.append(ImageItem(url: fileURL))
                if items.count.isMultiple(of: 100) {
                    loadingCount = items.count
                    await Task.yield()
                }
            }
        }
        loadingCount = items.count

        items.sort { $0.filename.localizedStandardCompare($1.filename) == .orderedAscending }
        return items
    }

    func trashImages(_ items: Set<ImageItem>) {
        var trashedIDs = Set<UUID>()
        var failedNames: [String] = []
        for item in items {
            do {
                try FileManager.default.trashItem(at: item.url, resultingItemURL: nil)
                trashedIDs.insert(item.id)
            } catch {
                failedNames.append(item.filename)
            }
        }
        if !failedNames.isEmpty {
            lastError = String(localized: "Impossible de mettre à la corbeille : \(failedNames.joined(separator: ", "))")
        }
        Task { @MainActor in
            self.images.removeAll { trashedIDs.contains($0.id) }
        }
    }

    func trashImage(_ item: ImageItem) {
        trashImages(Set([item]))
    }
}
