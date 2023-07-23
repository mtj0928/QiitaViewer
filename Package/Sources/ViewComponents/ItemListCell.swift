import Core
import SwiftUI

public struct ItemListCell: View {
    let item: Item

    public init(item: Item) {
        self.item = item
    }

    public var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    AsyncImage(url: item.user.profileImageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                        default: Color.gray
                        }
                    }
                    .clipShape(Circle())
                    .frame(width: 20, height: 20)
                    Text(item.user.displayName)
                        .font(.footnote)
                }
                Text(item.title)
                    .font(.subheadline)
                    .bold()
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
            HStack {
                Text(Image(systemName: "bubble.left.fill"))
                + Text(" \(item.commentsCount)")
                Text(Image(systemName: "heart.fill"))
                + Text(" \(item.likesCount)")
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .foregroundStyle(.secondary)
            .font(.caption2)
        }
    }
}

struct ItemListCell_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ItemListCell(item: .dummy1)
        }
        .listStyle(.plain)
    }
}
