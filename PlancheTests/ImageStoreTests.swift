import XCTest
@testable import Planche

/// Planche shows a folder of images. Two of its decisions are invisible until
/// they are wrong: which files count as images, and in what order they appear.
/// Neither raises anything — a missing photo just looks like a photo that was
/// never there, and a bad sort looks like the folder was always that way.
@MainActor
final class ImageStoreTests: XCTestCase {

    private var sandbox: URL!

    override func setUpWithError() throws {
        sandbox = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("planche-tests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: sandbox, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: sandbox)
    }

    private func place(_ names: [String]) throws {
        for name in names {
            try Data().write(to: sandbox.appendingPathComponent(name))
        }
    }

    func testOnlyImageExtensionsAreKept() async throws {
        try place(["a.jpg", "b.png", "c.heic", "notes.txt", "scan.pdf", "archive.zip", "d.webp"])

        let names = await ImageStore().scanImagesAsync(in: sandbox).map(\.filename).sorted()

        XCTAssertEqual(names, ["a.jpg", "b.png", "c.heic", "d.webp"])
    }

    func testTheExtensionMatchIsCaseInsensitive() async throws {
        // A camera that writes .JPG must not produce an empty gallery.
        try place(["PHOTO.JPG", "Other.PnG"])

        let names = await ImageStore().scanImagesAsync(in: sandbox).map(\.filename).sorted()

        XCTAssertEqual(names.count, 2, "uppercase extensions were dropped")
    }

    func testFilesAreSortedTheWayAHumanCounts() async throws {
        // localizedStandardCompare, not `<`: a plain string sort puts img10
        // before img2, and a hundred-photo folder reads as shuffled.
        try place(["img10.jpg", "img2.jpg", "img1.jpg", "img20.jpg"])

        let names = await ImageStore().scanImagesAsync(in: sandbox).map(\.filename)

        XCTAssertEqual(names, ["img1.jpg", "img2.jpg", "img10.jpg", "img20.jpg"])
    }

    func testHiddenFilesAreSkipped() async throws {
        try place(["visible.jpg", ".hidden.jpg"])

        let names = await ImageStore().scanImagesAsync(in: sandbox).map(\.filename)

        XCTAssertEqual(names, ["visible.jpg"])
    }

    func testAFailedTrashKeepsTheImageAndSaysSo() async throws {
        // The item is removed from the list on success only. If a delete that
        // failed still cleared the row, the photo would vanish from the gallery
        // while staying on disk.
        let store = ImageStore()
        let ghost = ImageItem(url: sandbox.appendingPathComponent("never-written.jpg"))
        store.images = [ghost]

        store.trashImages([ghost])
        await Task.yield()

        XCTAssertEqual(store.images.count, 1, "an image that could not be trashed left the list")
        XCTAssertNotNil(store.lastError)
    }
}
