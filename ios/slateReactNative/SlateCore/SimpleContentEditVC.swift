//
//  SimpleContentEditVC.swift
//  slateReactNative
//
//  Simplified version of Slate's ContentEditVC for React Native integration
//

import UIKit
import AVFoundation

@objc public class SimpleContentEditVC: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var mainContentView: UIView?
    @IBOutlet weak var buttonClose: UIButton?
    @IBOutlet weak var labelTitle: UILabel?
    
    var draftId: String?
    var onWorkspaceComplete: ((String?) -> Void)?
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDemoContent()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar for full-screen experience
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Create close button if not from storyboard
        if buttonClose == nil {
            buttonClose = UIButton(type: .system)
            buttonClose?.setTitle("✕ Close", for: .normal)
            buttonClose?.setTitleColor(.white, for: .normal)
            buttonClose?.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            buttonClose?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            buttonClose?.layer.cornerRadius = 8
            buttonClose?.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            
            view.addSubview(buttonClose!)
            buttonClose?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                buttonClose!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                buttonClose!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                buttonClose!.widthAnchor.constraint(equalToConstant: 80),
                buttonClose!.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        // Create title label if not from storyboard
        if labelTitle == nil {
            labelTitle = UILabel()
            labelTitle?.textColor = .white
            labelTitle?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            labelTitle?.textAlignment = .center
            
            view.addSubview(labelTitle!)
            labelTitle?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                labelTitle!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                labelTitle!.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80)
            ])
        }
        
        // Create main content area if not from storyboard
        if mainContentView == nil {
            mainContentView = UIView()
            mainContentView?.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            mainContentView?.layer.cornerRadius = 12
            mainContentView?.layer.borderWidth = 2
            mainContentView?.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            
            view.addSubview(mainContentView!)
            mainContentView?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                mainContentView!.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                mainContentView!.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                mainContentView!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
                mainContentView!.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5)
            ])
        }
    }
    
    private func setupDemoContent() {
        labelTitle?.text = draftId != nil ? "Editing Draft" : "New Project"
        
        // Add demo editing interface
        guard let contentView = mainContentView else { return }
        
        // Demo timeline
        let timelineView = UIView()
        timelineView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        timelineView.layer.cornerRadius = 8
        contentView.addSubview(timelineView)
        
        timelineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timelineView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            timelineView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            timelineView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            timelineView.heightAnchor.constraint(equalToConstant: 80)
        ])
        
        // Demo media area
        let mediaArea = UIView()
        mediaArea.backgroundColor = UIColor.blue.withAlphaComponent(0.2)
        mediaArea.layer.cornerRadius = 8
        mediaArea.layer.borderWidth = 1
        mediaArea.layer.borderColor = UIColor.blue.withAlphaComponent(0.5).cgColor
        contentView.addSubview(mediaArea)
        
        mediaArea.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mediaArea.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mediaArea.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mediaArea.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mediaArea.bottomAnchor.constraint(equalTo: timelineView.topAnchor, constant: -20)
        ])
        
        // Demo text
        let demoLabel = UILabel()
        demoLabel.text = """
        🎬 Slate Workspace Demo
        
        This is a simplified version of the 
        real Slate editing interface!
        
        Draft ID: \(draftId ?? "New Project")
        
        In the full integration, this would show:
        • Real media timeline
        • Video/photo editing tools
        • Text overlays
        • Filters and effects
        • Export capabilities
        """
        demoLabel.textColor = .white
        demoLabel.textAlignment = .center
        demoLabel.numberOfLines = 0
        demoLabel.font = UIFont.systemFont(ofSize: 16)
        
        mediaArea.addSubview(demoLabel)
        demoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            demoLabel.centerXAnchor.constraint(equalTo: mediaArea.centerXAnchor),
            demoLabel.centerYAnchor.constraint(equalTo: mediaArea.centerYAnchor),
            demoLabel.leadingAnchor.constraint(equalTo: mediaArea.leadingAnchor, constant: 20),
            demoLabel.trailingAnchor.constraint(equalTo: mediaArea.trailingAnchor, constant: -20)
        ])
        
        // Add action buttons
        createActionButtons(in: contentView)
    }
    
    private func createActionButtons(in parentView: UIView) {
        let buttonStack = UIStackView()
        buttonStack.axis = .horizontal
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 15
        
        // Save button
        let saveButton = createActionButton(title: "💾 Save", backgroundColor: .systemGreen)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        // Export button  
        let exportButton = createActionButton(title: "📤 Export", backgroundColor: .systemBlue)
        exportButton.addTarget(self, action: #selector(exportButtonTapped), for: .touchUpInside)
        
        // Share button
        let shareButton = createActionButton(title: "📱 Share", backgroundColor: .systemOrange)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        buttonStack.addArrangedSubview(saveButton)
        buttonStack.addArrangedSubview(exportButton)
        buttonStack.addArrangedSubview(shareButton)
        
        parentView.addSubview(buttonStack)
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonStack.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 40),
            buttonStack.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -40),
            buttonStack.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 60),
            buttonStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func createActionButton(title: String, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 8
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return button
    }
    
    // MARK: - Actions
    
    @objc private func closeButtonTapped() {
        onWorkspaceComplete?(draftId)
        
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func saveButtonTapped() {
        showAlert(title: "💾 Save", message: "Project saved successfully!")
    }
    
    @objc private func exportButtonTapped() {
        showAlert(title: "📤 Export", message: "Exporting your video...")
    }
    
    @objc private func shareButtonTapped() {
        showAlert(title: "📱 Share", message: "Opening share options...")
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - Public Interface for React Native

@objc extension SimpleContentEditVC {
    
    @objc public static func createFromStoryboard(draftId: String?) -> SimpleContentEditVC? {
        // Try to load from storyboard first
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ContentEditVC") as? SimpleContentEditVC {
            vc.draftId = draftId
            return vc
        }
        
        // Fallback to programmatic creation
        let vc = SimpleContentEditVC()
        vc.draftId = draftId
        return vc
    }
    
    @objc public func setOnComplete(_ completion: @escaping (String?) -> Void) {
        onWorkspaceComplete = completion
    }
} 