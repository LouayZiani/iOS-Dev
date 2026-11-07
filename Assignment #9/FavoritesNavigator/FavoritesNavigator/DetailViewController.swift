import UIKit

class DetailViewController: UIViewController {

    /// Set by ListViewController in prepare(for:sender:).
    var item: FavoriteItem?

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet var starImageViews: [UIImageView]!   // 5 stars, tags 1...5
    @IBOutlet weak var descriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item = item else { return }

        title = item.title                      // small title in the navigation bar
        coverImageView.image = UIImage(named: item.imageName)
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        descriptionLabel.text = item.description

        // Rating as SF Symbols: filled star up to the rating, empty star after it
        for star in starImageViews {
            star.image = UIImage(systemName: star.tag <= item.rating ? "star.fill" : "star")
        }
    }
}
