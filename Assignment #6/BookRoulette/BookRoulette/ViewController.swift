import UIKit

class ViewController: UIViewController {


    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var spinButton: UIButton!


    private let favorites: [Favorite] = [
        Favorite(imageName: "book_sans_famille",
                 title: "Sans Famille",
                 description: "Hector Malot, 1878. A foundling boy, Rémi, crosses France with a travelling musician and his animals."),
        Favorite(imageName: "book_letranger",
                 title: "L’Étranger",
                 description: "Albert Camus, 1942. A detached clerk in Algiers kills a man and is judged as much for his indifference as for the crime."),
        Favorite(imageName: "book_une_vie",
                 title: "Une Vie",
                 description: "Guy de Maupassant, 1883. Jeanne, raised in innocence, watches her marriage and her hopes slowly fall apart."),
        Favorite(imageName: "book_la_curee",
                 title: "La Curée",
                 description: "Émile Zola, 1872. Second Empire Paris, where speculation and appetite consume Renée and everyone around her."),
        Favorite(imageName: "book_mockingbird",
                 title: "To Kill a Mockingbird",
                 description: "Harper Lee, 1960. Scout Finch grows up in Depression-era Alabama while her father defends a Black man falsely accused."),
        Favorite(imageName: "book_les_miserables",
                 title: "Les Misérables",
                 description: "Victor Hugo, 1862. Jean Valjean, an ex-convict, tries to build an honest life while Inspector Javert hunts him."),
        Favorite(imageName: "book_don_quixote",
                 title: "Don Quixote",
                 description: "Miguel de Cervantes, 1605. A gentleman reads too many chivalry novels and sets out as a knight, with Sancho Panza at his side."),
        Favorite(imageName: "book_dorian_gray",
                 title: "The Picture of Dorian Gray",
                 description: "Oscar Wilde, 1890. A beautiful young man stays unchanged while his portrait absorbs the cost of his choices."),
        Favorite(imageName: "book_candide",
                 title: "Candide",
                 description: "Voltaire, 1759. A naive young man is thrown from disaster to disaster while being told that all is for the best."),
        Favorite(imageName: "book_bourgeois",
                 title: "Le Bourgeois gentilhomme",
                 description: "Molière, 1670. Monsieur Jourdain, a rich merchant, tries to pass for a nobleman and gets played by everyone around him.")
    ]

    private var lastIndex: Int?


    private let initialImageName = "Placeholder"
    private let initialTitle = "My Top 10 Books"
    private let initialDescription = "Ten books I love. Tap the button to draw one at random."


    override func viewDidLoad() {
        super.viewDidLoad()
        spinButton.layer.cornerRadius = 14
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        showInitialState()
    }


    @IBAction func spinTapped(_ sender: UIButton) {
        guard let index = randomIndex() else { return }
        lastIndex = index
        show(favorites[index])
    }



    private func randomIndex() -> Int? {
        var candidates = Array(favorites.indices)
        if let last = lastIndex {
            candidates.removeAll { $0 == last }
        }
        return candidates.randomElement()
    }

    private func showInitialState() {
        coverImageView.image = UIImage(named: initialImageName)
        titleLabel.text = initialTitle
        descriptionLabel.text = initialDescription
    }


    private func show(_ favorite: Favorite) {
        UIView.transition(with: view,
                          duration: 0.25,
                          options: .transitionCrossDissolve,
                          animations: {
            self.coverImageView.image = UIImage(named: favorite.imageName)
            self.titleLabel.text = favorite.title
            self.descriptionLabel.text = favorite.description
        }, completion: nil)
    }
}
