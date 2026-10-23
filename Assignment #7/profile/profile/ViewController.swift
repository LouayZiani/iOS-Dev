//
//  ViewController.swift
//  profile
//
//  Created by Louay Ziani on 23.10.2026.
//

import UIKit

final class ProfileViewController: UIViewController {

    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!

    @IBOutlet private weak var postsValueLabel: UILabel!
    @IBOutlet private weak var followersValueLabel: UILabel!
    @IBOutlet private weak var followingValueLabel: UILabel!

    @IBOutlet private weak var aboutLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        avatarImageView.image = UIImage(
            systemName: "person.crop.circle.fill"
        )
        avatarImageView.tintColor = .systemIndigo

        nameLabel.text = "Louay Ziani"

        postsValueLabel.text = "128"
        followersValueLabel.text = "4.2K"
        followingValueLabel.text = "312"

        aboutLabel.text = """
        Senior Computer Systems and Software student at KBTU.
        Interested in AI, human-computer interaction, and building
        useful technology.
        """
    }
}
