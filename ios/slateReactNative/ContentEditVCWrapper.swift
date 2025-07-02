import UIKit
import AVFoundation
import AVKit
import Photos

// A wrapper that can work with or without the actual ContentEditVC
class ContentEditVCWrapper: UIViewController {
    
    // MARK: - Properties
    var draftId: String?
    private var playerViewController: AVPlayerViewController?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationBar()
        
        // Check if we have a draft to load
        if let draftId = draftId {
            loadDraft(withId: draftId)
        } else {
            showMediaPicker()
        }
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Add a placeholder view
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Slate Video Editor"
        placeholderLabel.textColor = .white
        placeholderLabel.font = .systemFont(ofSize: 24, weight: .bold)
        placeholderLabel.textAlignment = .center
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Edit Video"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func doneTapped() {
        // In a real implementation, this would save/export the video
        dismiss(animated: true)
    }
    
    // MARK: - Draft Loading
    
    private func loadDraft(withId id: String) {
        // Placeholder for loading draft
        print("Loading draft with ID: \(id)")
    }
    
    // MARK: - Media Picker
    
    private func showMediaPicker() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard status == .authorized else {
                DispatchQueue.main.async {
                    self?.showPermissionAlert()
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.presentVideoPicker()
            }
        }
    }
    
    private func presentVideoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = ["public.movie"]
        present(picker, animated: true)
    }
    
    private func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Permission Required",
            message: "Please allow access to your photo library to select videos.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Video Playback
    
    private func playVideo(at url: URL) {
        let player = AVPlayer(url: url)
        playerViewController = AVPlayerViewController()
        playerViewController?.player = player
        
        if let playerVC = playerViewController {
            addChild(playerVC)
            view.addSubview(playerVC.view)
            playerVC.view.frame = view.bounds
            playerVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            playerVC.didMove(toParent: self)
            
            player.play()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ContentEditVCWrapper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let videoURL = info[.mediaURL] as? URL {
            playVideo(at: videoURL)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
        cancelTapped()
    }
} 