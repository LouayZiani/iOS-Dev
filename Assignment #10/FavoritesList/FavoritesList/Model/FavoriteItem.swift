import Foundation

/// One entry of the favorites list.
struct FavoriteItem {
    let title: String
    let subtitle: String
    /// Name of an image set in Assets.xcassets.
    let imageName: String
    /// 0...5
    let rating: Int
}
