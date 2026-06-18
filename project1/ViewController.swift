import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var hiLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sideLabel: UILabel!
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!

    let locationManager = CLLocationManager()
    let middleLongitude = 34.817549168324334

    var userSide = ""
    var hasLocation = false

    override func viewDidLoad() {
        super.viewDidLoad()

        startButton.configuration = nil
        startButton.isHidden = true
        sideLabel.text = ""

        if let savedName = UserDefaults.standard.string(forKey: "playerName") {
            hiLabel.text = "Hi \(savedName)"
            nameTextField.text = savedName
            nameTextField.isHidden = true
        } else {
            hiLabel.text = "Hi"
            nameTextField.isHidden = false
        }

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        updateAppearance()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateAppearance()
    }

    // Updates the main screen colors, button style and images for Light/Dark mode.
    func updateAppearance() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark

        view.backgroundColor = isDarkMode ? .black : .white

        hiLabel.textColor = isDarkMode ? .white : .black
        sideLabel.textColor = isDarkMode ? .white : .black

        nameTextField.attributedPlaceholder = NSAttributedString(
            string: "Enter your name",
            attributes: [.foregroundColor: isDarkMode ? UIColor.lightGray : UIColor.systemGray]
        )

        leftImageView.image = UIImage(named: isDarkMode ? "left_night" : "earth_left")
        rightImageView.image = UIImage(named: isDarkMode ? "right_night" : "earth_right")

        if isDarkMode {
            startButton.backgroundColor = .systemBlue
            startButton.setTitleColor(.white, for: .normal)
        } else {
            startButton.backgroundColor = UIColor(red: 0.82, green: 0.65, blue: 0.52, alpha: 1.0)
            startButton.setTitleColor(.black, for: .normal)
        }

        startButton.setTitle("Start", for: .normal)
        startButton.layer.cornerRadius = 8
        startButton.clipsToBounds = true
    }

    // Gets the current location, decides East/West side and enables the Start button.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        let longitude = location.coordinate.longitude

        if longitude > middleLongitude {
            userSide = "East Side"
        } else {
            userSide = "West Side"
        }

        hasLocation = true
        sideLabel.text = userSide
        startButton.isHidden = false

        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    // Validates that name and location exist, saves the name and starts the game.
    @IBAction func startButtonTapped(_ sender: UIButton) {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if name.isEmpty || !hasLocation {
            return
        }

        UserDefaults.standard.set(name, forKey: "playerName")
        hiLabel.text = "Hi \(name)"
        nameTextField.isHidden = true

        performSegue(withIdentifier: "showGame", sender: self)
    }

    // Sends the player's name and side to the game screen.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gameVC = segue.destination as? GameViewController {
            gameVC.playerName = nameTextField.text ?? "Player"
            gameVC.userSide = userSide
        }
    }
}
