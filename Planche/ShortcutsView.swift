import SwiftUI

struct ShortcutsView: View {
    @Environment(\.dismiss) private var dismiss

    private let general: [(key: LocalizedStringKey, action: LocalizedStringKey)] = [
        ("⌘O", "Ouvrir un dossier"),
        ("⌘A", "Tout sélectionner"),
        ("⌫", "Supprimer la sélection"),
    ]

    private let detail: [(key: LocalizedStringKey, action: LocalizedStringKey)] = [
        ("Espace", "Ouvrir / fermer"),
        ("← →", "Image précédente / suivante"),
        ("Échap", "Fermer"),
        ("⌫", "Mettre à la corbeille"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Raccourcis clavier")
                    .font(.headline)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    section("Général", shortcuts: general)
                    section("Vue détaillée", shortcuts: detail)
                }
                .padding()
            }
        }
        .frame(width: 340, height: 280)
    }

    private func section(_ title: LocalizedStringKey, shortcuts: [(key: LocalizedStringKey, action: LocalizedStringKey)]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundColor(.secondary)

            ForEach(Array(shortcuts.enumerated()), id: \.offset) { _, shortcut in
                HStack {
                    Text(shortcut.key)
                        .font(.system(.body, design: .rounded).bold())
                        .frame(width: 60, alignment: .trailing)
                        .foregroundColor(.accentColor)
                    Text(shortcut.action)
                    Spacer()
                }
            }
        }
    }
}
