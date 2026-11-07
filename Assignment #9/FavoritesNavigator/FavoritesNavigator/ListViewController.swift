import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let items = FavoriteLibrary.items

    // Deselect the tapped row when we come back from the Detail screen
    // (this also covers the edge-swipe back gesture).
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selected, animated: true)
        }
    }

    // The Show segue goes from the prototype cell to the Detail screen.
    // We only pass data here, we never touch the Detail screen's labels or image views.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showDetail",
              let detail = segue.destination as? DetailViewController,
              let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        detail.item = items[indexPath.row]
    }
}

// MARK: - UITableViewDataSource (dataSource outlet is connected in Main.storyboard)

extension ListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCell", for: indexPath) as? FavoriteCell else {
            return UITableViewCell()
        }
        cell.configure(with: items[indexPath.row])
        return cell
    }
}
