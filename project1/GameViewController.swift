import UIKit
import AVFoundation

class GameViewController: UIViewController {

    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var player0Label: UILabel!
    @IBOutlet weak var pcLabel: UILabel!
    @IBOutlet weak var pc0Label: UILabel!
    @IBOutlet weak var timerLabel: UILabel!

    @IBOutlet weak var playerCardImageView: UIImageView!
    @IBOutlet weak var pcCardImageView: UIImageView!

    var playerName = "Player"
    var userSide = ""

    var playerScore = 0
    var pcScore = 0
    var round = 0
    var seconds = 5
    var timer: Timer?

    var lastPlayerCardName = ""
    var lastPcCardName = ""

    var backgroundPlayer: AVAudioPlayer?
    var effectPlayer: AVAudioPlayer?

    let cards = [
        ("001-ace of spades", 14),
        ("002-ace of clubs", 14),
        ("003-ace of diamonds", 14),
        ("004-ace of hearts", 14),
        ("021-six of spades", 6),
        ("025-seven of spades", 7),
        ("029-eight of spades", 8),
        ("033-nine of spades", 9),
        ("037-ten of spades", 10),
        ("041-jack of spades", 11),
        ("045-queen of spades", 12),
        ("049-king of spades", 13)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        playerLabel.text = playerName
        player0Label.text = "0"
        pcLabel.text = "PC"
        pc0Label.text = "0"
        timerLabel.text = "5"

        updateAppearance()
        playBackgroundMusic()
        startGame()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if round < 10 {
            playBackgroundMusic()
        }

        if timer == nil && round < 10 {
            startGame()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
        backgroundPlayer?.stop()
    }

    // Updates the game screen colors for Light/Dark mode.
    func updateAppearance() {
        let isDarkMode = traitCollection.userInterfaceStyle == .dark

        view.backgroundColor = isDarkMode ? .black : .white

        playerLabel.textColor = isDarkMode ? .white : .black
        player0Label.textColor = isDarkMode ? .white : .black
        pcLabel.textColor = isDarkMode ? .white : .black
        pc0Label.textColor = isDarkMode ? .white : .black
        timerLabel.textColor = isDarkMode ? .white : .black
    }

    // Plays background music in a loop during the game.
    func playBackgroundMusic() {
        if backgroundPlayer?.isPlaying == true {
            return
        }

        guard let url = Bundle.main.url(forResource: "Background Music", withExtension: "mp3") else {
            print("Background Music file not found")
            return
        }

        do {
            backgroundPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundPlayer?.numberOfLoops = -1
            backgroundPlayer?.volume = 0.3
            backgroundPlayer?.play()
        } catch {
            print("Background music error: \(error.localizedDescription)")
        }
    }

    // Plays a short sound effect.
    func playSound(name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("\(name) file not found")
            return
        }

        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.play()
        } catch {
            print("Sound error: \(error.localizedDescription)")
        }
    }

    // Starts the countdown timer and plays a round every 5 seconds.
    func startGame() {
        if timer != nil {
            return
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.seconds -= 1
            self.timerLabel.text = "\(self.seconds)"

            if self.seconds == 0 {
                self.seconds = 5
                self.playRound()
            }
        }
    }

    // Stops the timer when leaving the game screen.
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // Plays one round, chooses two new cards, compares them and updates the score.
    func playRound() {
        if round >= 10 {
            goToResultScreen()
            return
        }

        round += 1
        seconds = 5
        timerLabel.text = "5"

        var playerCard = cards.randomElement()!
        var pcCard = cards.randomElement()!

        while playerCard.0 == pcCard.0 ||
                playerCard.0 == lastPlayerCardName ||
                pcCard.0 == lastPcCardName {

            playerCard = cards.randomElement()!
            pcCard = cards.randomElement()!
        }

        lastPlayerCardName = playerCard.0
        lastPcCardName = pcCard.0

        playerCardImageView.image = UIImage(named: playerCard.0)
        pcCardImageView.image = UIImage(named: pcCard.0)

        playSound(name: "Card Flip Sound")

        if playerCard.1 > pcCard.1 {
            playerScore += 1
        } else if pcCard.1 > playerCard.1 {
            pcScore += 1
        }

        player0Label.text = "\(playerScore)"
        pc0Label.text = "\(pcScore)"
    }

    // Opens the result screen and sends the winner details.
    func goToResultScreen() {
        stopTimer()
        backgroundPlayer?.stop()
        playSound(name: "Victory Sound")

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let resultVC = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController

        if playerScore > pcScore {
            resultVC.winnerText = "Winner: \(playerName)"
            resultVC.scoreText = "score: \(playerScore)"
        } else if pcScore > playerScore {
            resultVC.winnerText = "Winner: PC"
            resultVC.scoreText = "score: \(pcScore)"
        } else {
            resultVC.winnerText = "It's a Tie!"
            resultVC.scoreText = "score: \(playerScore) - \(pcScore)"
        }

        resultVC.modalPresentationStyle = .fullScreen
        present(resultVC, animated: true)
    } 
}
