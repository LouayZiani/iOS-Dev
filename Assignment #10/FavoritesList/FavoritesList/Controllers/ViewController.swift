import UIKit

final class ViewController: UIViewController, UITableViewDataSource {

    // Must match the reuse identifier of the prototype cell in Main.storyboard.
    private let cellIdentifier = "FavoriteCell"

    private let items = FavoriteLibrary.items

    // The table view's dataSource outlet is connected to this controller in Main.storyboard.

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,
                                                       for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        cell.configure(with: items[indexPath.row])
        return cell
    }
}
