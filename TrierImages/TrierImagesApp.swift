import SwiftUI

@main
struct TrierImagesApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowToolbarStyle(.unified)
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Ouvrir un dossier...") {
                    NotificationCenter.default.post(name: .openFolder, object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            CommandGroup(replacing: .help) {
                Button("Raccourcis clavier") {
                    NotificationCenter.default.post(name: .showShortcuts, object: nil)
                }
                .keyboardShortcut("/", modifiers: .command)
            }
        }
    }
}

extension Notification.Name {
    static let openFolder = Notification.Name("openFolder")
    static let showShortcuts = Notification.Name("showShortcuts")
}
