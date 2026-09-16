import SwiftUI
import AppKit
import ImageIO

class ThumbnailCache {
    static let shared = ThumbnailCache()

    private let cache = NSCache<NSURL, NSImage>()
    private let queue = DispatchQueue(label: "thumbnailLoader", qos: .userInitiated, attributes: .concurrent)

    init() {
        cache.countLimit = 2000
        cache.totalCostLimit = 512 * 1024 * 1024
    }

    func thumbnail(for url: URL, size: CGFloat, completion: @escaping (NSImage?) -> Void) {
        let key = url as NSURL

        if let cached = cache.object(forKey: key) {
            completion(cached)
            return
        }

        queue.async { [weak self] in
            let options: [CFString: Any] = [
                kCGImageSourceThumbnailMaxPixelSize: size,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true,
            ]

            guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
                  let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            let thumb = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
            let cost = cgImage.width * cgImage.height * 4
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
