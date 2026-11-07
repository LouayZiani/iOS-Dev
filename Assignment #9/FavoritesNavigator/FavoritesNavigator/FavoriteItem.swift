import Foundation

/// One favorite thing. The theme of this app is movies.
struct FavoriteItem {
    let title: String
    let subtitle: String
    let imageName: String      // name of the image in Assets.xcassets
    let rating: Int            // 0...5
    let description: String    // at least 3 sentences
}
