import SwiftUI
import AppKit

class ThumbnailCache {
    static let shared = ThumbnailCache()

    private let cache = NSCache<NSURL, NSImage>()
    private let queue = DispatchQueue(label: "thumbnailLoader", qos: .userInitiated, attributes: .concurrent)

    init() {
        cache.countLimit = 2000
        cache.totalCostLimit = 512 * 1024 * 1024 // 512 MB
    }

    func thumbnail(for url: URL, size: CGFloat, completion: @escaping (NSImage?) -> Void) {
        let key = url as NSURL

        if let cached = cache.object(forKey: key) {
            completion(cached)
            return
        }

        queue.async { [weak self] in
            guard let image = NSImage(contentsOf: url) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let originalSize = image.size
            guard originalSize.width > 0 && originalSize.height > 0 else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let scale = min(size / originalSize.width, size / originalSize.height, 1.0)
            let newSize = NSSize(
                width: round(originalSize.width * scale),
                height: round(originalSize.height * scale)
            )

            let bitmapRep = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(newSize.width),
                pixelsHigh: Int(newSize.height),
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: .deviceRGB,
                bytesPerRow: 0,
                bitsPerPixel: 0
            )!
            let context = NSGraphicsContext(bitmapImageRep: bitmapRep)!
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = context
            image.draw(in: NSRect(origin: .zero, size: newSize),
                       from: NSRect(origin: .zero, size: originalSize),
                       operation: .copy,
                       fraction: 1.0)
            NSGraphicsContext.restoreGraphicsState()

            let thumb = NSImage(size: newSize)
            thumb.addRepresentation(bitmapRep)

            let cost = Int(newSize.width * newSize.height * 4)
            self?.cache.setObject(thumb, forKey: key, cost: cost)

            DispatchQueue.main.async { completion(thumb) }
        }
    }
}

struct ThumbnailImageView: View {
    let url: URL
    let size: CGFloat

    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .overlay {
                        ProgressView()
                            .scaleEffect(0.5)
                    }
            }
        }
        .frame(width: size, height: size)
        .onAppear { loadThumbnail() }
        .onChange(of: url) { loadThumbnail() }
    }

    private func loadThumbnail() {
        ThumbnailCache.shared.thumbnail(for: url, size: size * 2) { thumb in
            self.image = thumb
        }
    }
}

struct FullImageView: View {
    let url: URL

    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.black
                    .overlay {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
            }
        }
        .onAppear { loadImage() }
        .onChange(of: url) { loadImage() }
    }

    private func loadImage() {
        self.image = nil
        let fileURL = url
        Task.detached(priority: .userInitiated) {
            let loaded = NSImage(contentsOf: fileURL)
            await MainActor.run {
                self.image = loaded
            }
        }
    }
}
