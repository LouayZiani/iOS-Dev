import UIKit

/// Prototype cell from Main.storyboard: cover image + title only.
class FavoriteCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    func configure(with item: FavoriteItem) {
        coverImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
    }
}
