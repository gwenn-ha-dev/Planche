import SwiftUI

struct ThumbnailView: View {
    let item: ImageItem
    let isSelected: Bool
    let size: CGFloat

    @State private var isHovered = false

    var body: some View {
        VStack(spacing: 4) {
            ThumbnailImageView(url: item.url, size: size - 16)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)

            Text(item.filename)
                .font(.caption2)
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: size - 8)
        }
        .padding(6)
        .frame(width: size, height: size + 20)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(backgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isHovered && !isSelected ? 1.03 : 1.0)
        .animation(.easeOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .accessibilityLabel(item.filename)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.25)
        } else if isHovered {
            return Color.primary.opacity(0.06)
        } else {
            return Color.clear
        }
    }
}
