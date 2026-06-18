import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var backToMenuButton: UIButton!

    var winnerText = ""
    var scoreText = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        winnerLabel.text = winnerText
        scoreLabel.text = scoreText

        updateAppearance()
    }

    // Updates the result screen colors and button style for Light/Dark mode.
    func updateAppearance() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark

        view.backgroundColor = isDarkMode ? .black : .white

        winnerLabel.textColor = isDarkMode ? .white : .black
        scoreLabel.textColor = isDarkMode ? .white : .black

        backToMenuButton.configuration = nil
        backToMenuButton.backgroundColor = isDarkMode ? .systemBlue : UIColor(red: 0.82, green: 0.65, blue: 0.52, alpha: 1)
        backToMenuButton.setTitleColor(isDarkMode ? .white : .black, for: .normal)
        backToMenuButton.setTitle("BACK TO MENU", for: .normal)
        backToMenuButton.layer.cornerRadius = 8
        backToMenuButton.clipsToBounds = true
    }

    // Returns from the result screen back to the main menu.
    @IBAction func backToMenuTapped(_ sender: UIButton) {
        presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
}
