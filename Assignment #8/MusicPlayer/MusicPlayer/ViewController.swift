import UIKit
import AVFoundation

final class ViewController: UIViewController, AVAudioPlayerDelegate {

    // MARK: - Outlets

    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var artistLabel: UILabel!

    @IBOutlet private weak var previousButton: UIButton!
    @IBOutlet private weak var playPauseButton: UIButton!
    @IBOutlet private weak var nextButton: UIButton!


    // MARK: - Player State

    private let tracks = TrackLibrary.tracks

    private var currentTrackIndex = 0
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false


    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureButtons()
        coverImageView.layer.cornerRadius = 12
        coverImageView.clipsToBounds = true
        loadTrack(at: currentTrackIndex, shouldPlay: false)
    }


    // MARK: - Interface Setup

    private func configureButtons() {

        previousButton.setImage(
            UIImage(systemName: "backward.fill"),
            for: .normal
        )

        playPauseButton.setImage(
            UIImage(systemName: "play.fill"),
            for: .normal
        )

        nextButton.setImage(
            UIImage(systemName: "forward.fill"),
            for: .normal
        )

        let symbolSize = UIImage.SymbolConfiguration(
            pointSize: 28,
            weight: .semibold
        )

        previousButton.setPreferredSymbolConfiguration(
            symbolSize,
            forImageIn: .normal
        )

        playPauseButton.setPreferredSymbolConfiguration(
            symbolSize,
            forImageIn: .normal
        )

        nextButton.setPreferredSymbolConfiguration(
            symbolSize,
            forImageIn: .normal
        )

        previousButton.tintColor = .label
        playPauseButton.tintColor = .systemIndigo
        nextButton.tintColor = .label

        previousButton.accessibilityLabel = "Previous track"
        playPauseButton.accessibilityLabel = "Play"
        nextButton.accessibilityLabel = "Next track"
    }


    // MARK: - Load Track

    private func loadTrack(at index: Int, shouldPlay: Bool) {

        guard !tracks.isEmpty else {
            print("The track library is empty.")
            return
        }

        currentTrackIndex = index

        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false

        let track = tracks[currentTrackIndex]

        // Update the interface

        titleLabel.text = track.title
        artistLabel.text = track.artist

        coverImageView.image = UIImage(
            named: track.coverImageName
        )

        coverImageView.contentMode = .scaleAspectFill

        if coverImageView.image == nil {
            print("Missing cover image: \(track.coverImageName)")
        }

        // Find the audio file in the app bundle

        guard let audioURL = Bundle.main.url(
            forResource: track.fileName,
            withExtension: "mp3"
        ) else {
            print("Missing audio file: \(track.fileName).mp3")
            updatePlayButton()
            return
        }

        // Create the audio player

        do {

            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)

            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()

            if shouldPlay {
                audioPlayer?.play()
                isPlaying = true
            }

        } catch {

            print("Could not load audio: \(error.localizedDescription)")
            audioPlayer = nil
            isPlaying = false
        }

        updatePlayButton()
    }


    // MARK: - Update Play Button

    private func updatePlayButton() {

        let symbolName = isPlaying ? "pause.fill" : "play.fill"

        playPauseButton.setImage(
            UIImage(systemName: symbolName),
            for: .normal
        )

        playPauseButton.accessibilityLabel =
            isPlaying ? "Pause" : "Play"
    }


    // MARK: - Play / Pause

    @IBAction private func playPauseTapped(_ sender: UIButton) {

        guard let player = audioPlayer else {
            print("No audio file is loaded.")
            return
        }

        if player.isPlaying {

            player.pause()
            isPlaying = false

        } else {

            if player.play() {
                isPlaying = true
            }
        }

        updatePlayButton()
    }


    // MARK: - Next Track

    @IBAction private func nextTapped(_ sender: UIButton) {

        let wasPlaying = isPlaying

        let nextIndex = (currentTrackIndex + 1) % tracks.count

        loadTrack(
            at: nextIndex,
            shouldPlay: wasPlaying
        )
    }


    // MARK: - Previous Track

    @IBAction private func previousTapped(_ sender: UIButton) {

        let wasPlaying = isPlaying

        let previousIndex =
            (currentTrackIndex - 1 + tracks.count) % tracks.count

        loadTrack(
            at: previousIndex,
            shouldPlay: wasPlaying
        )
    }


    // MARK: - Audio Finished

    func audioPlayerDidFinishPlaying(
        _ player: AVAudioPlayer,
        successfully flag: Bool
    ) {

        guard flag else {
            print("Audio playback did not finish successfully.")
            return
        }

        let nextIndex = (currentTrackIndex + 1) % tracks.count

        loadTrack(
            at: nextIndex,
            shouldPlay: true
        )
    }
}
