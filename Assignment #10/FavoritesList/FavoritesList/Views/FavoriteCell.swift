import UIKit

/// Prototype cell from Main.storyboard.
/// Only outlets + one method that fills the cell from an item. No layout code.
final class FavoriteCell: UITableViewCell {

    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    /// The 5 SF Symbol image views of the rating row, left to right.
    @IBOutlet private var starImageViews: [UIImageView]!

    func configure(with item: FavoriteItem) {
        itemImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle

        // Every star is set on every call, so a reused cell never keeps an old rating.
        for (index, star) in starImageViews.enumerated() {
            star.image = UIImage(systemName: index < item.rating ? "star.fill" : "star")
        }
    }
}
