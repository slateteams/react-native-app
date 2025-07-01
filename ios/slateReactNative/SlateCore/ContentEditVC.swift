//
//  ContentEditVC.swift
//  Story
//
//  Created by Yury Shubin on 5/12/18.
//  Copyright © 2018 Fontmoji. All rights reserved.
//

import AVFoundation
import Combine
import EasyTipView
import FMLib
import FMSharing
import FMTextView
import Foundation
import Presentr
import SlateAppData
import SlateServerData
import UIKit

final class ContentEditVC: ResponsiveVC {

    // MARK: - IBOutlets

    @IBOutlet private(set) var topBlackViewGesture: UITapGestureRecognizer!
    @IBOutlet private(set) var bottomBlackViewGesture: UITapGestureRecognizer!
    @IBOutlet private(set) weak var buttonSearch: UIButton!
    @IBOutlet private(set) weak var buttonSound: UIButton!
    @IBOutlet private(set) weak var buttonReset: UIButton!
    @IBOutlet private(set) weak var buttonMenu: UIButton!
    @IBOutlet private(set) weak var constraintButtonMenuTrailing: NSLayoutConstraint!
    @IBOutlet private(set) weak var constraintButtonSearchTrailing: NSLayoutConstraint!
    @IBOutlet private(set) weak var buttonDone: UIButton!
    @IBOutlet private(set) weak var buttonDimensionPresentation: UIButton!
    @IBOutlet private(set) weak var buttonTrash: UIButton!
    @IBOutlet private(set) weak var labelInstruction: UILabel!
    @IBOutlet private(set) weak var mediaLoadingView: MediaLoadingView!
    @IBOutlet private(set) weak var textAreaView: FontComposerTextAreaView!
    @IBOutlet private(set) weak var viewAssetsDuration: AssetDurationView!
    @IBOutlet private(set) weak var transparentBackgroundView: TransparentBackgroundView!
    @IBOutlet private(set) var snapZoneView: SnapZoneView!
    @IBOutlet private(set) weak var viewTopBlack: TopBottomView!
    @IBOutlet private(set) weak var viewBottomBlack: TopBottomView!
    @IBOutlet private(set) var maxLayersView: MaxLayersView!
    @IBOutlet private(set) var maxLayersViewOnTranslating: MaxLayersView!
    @IBOutlet private(set) var constraintSnapZoneTop: NSLayoutConstraint!
    @IBOutlet private var constraintSnapZoneBottom: NSLayoutConstraint!
    @IBOutlet private var constraintSnapZoneBottomX: NSLayoutConstraint!
    @IBOutlet private(set) var constraintSnapZoneHeight: NSLayoutConstraint!
    @IBOutlet private(set) weak var topBlackViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var bottomBlackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var leftBlackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var rightBlackViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var collectionFontsContainerView: UIVisualEffectView!
    @IBOutlet private(set) weak var collectionFontsButton: UIButton!
    @IBOutlet private(set) weak var collectionFontsButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet private var constraintButtonDimensionBottom: NSLayoutConstraint!
    @IBOutlet private var constraintButtonDimensionBottomX: NSLayoutConstraint!
    @IBOutlet private(set) var constraintTextViewBottom: NSLayoutConstraint!
    @IBOutlet private(set) var tapGestureView: UITapGestureRecognizer!
    @IBOutlet private(set) var backgroundViewTapGesture: UITapGestureRecognizer!
    @IBOutlet private(set) var snapHintsView: SnapHintsView!
    @IBOutlet private(set) var textModeDimView: UIView!
    @IBOutlet private(set) var overalDimView: UIView!
    @IBOutlet private(set) weak var contentEditingActionPanel: ContentEditingActionPanel!
    @IBOutlet private weak var contentEditingActionPanelHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var textOptionsContainerView: UIView!
    @IBOutlet private weak var textOptionsContainerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textOptionsContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var layoutPanel: LayoutPanelView!
    @IBOutlet private weak var gifImageView: GifImageView!
    @IBOutlet private(set) weak var labelTranscriptionDescription: UILabel!
    @IBOutlet private(set) weak var captionsLoadingView: UIView!
    @IBOutlet private(set) weak var animatableChevronView: AnimatableChevronView!
    @IBOutlet private(set) weak var timelineView: TimelineView!
    @IBOutlet private(set) weak var gestureTransitionContainer: UIView!
    @IBOutlet private(set) weak var undoContainer: UIStackView!
    @IBOutlet private(set) weak var undoButton: UIButton!
    @IBOutlet private(set) weak var redoButton: UIButton!
    @IBOutlet private(set) var scrubberView: ScrubberView!
    @IBOutlet private(set) var scrubberHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties

    var inText: String?
    var statusBarHidden = true
    var isTimelineChevronShown: Bool = false
    var viewBlur: UIVisualEffectViewAnimatable?
    var safezone: Safezone?
    var selectedAudio: BLAudio?
    var snapzoneInitialFrame: CGRect!
    var filterSwipeLeft: UISwipeGestureRecognizer!
    var filterSwipeRight: UISwipeGestureRecognizer!
    var textOptionsViewController: TextOptionsViewController!
    var textControllerCoordinator: TextControllerCoordinator!
    var snapshotView: UIView?
    var draftInterpretationManager: DraftInterpretationManager!
    var constraintMediaLoadingViewTop: NSLayoutConstraint!
    var dimension: ScreenDimension = .ratio_9_16
    var mode: Mode = .transforming
    var onReady: ResultBlockVoid?
    var observers: [NSObjectProtocol] = []
    var subscriptions = Set<AnyCancellable>()
    let changingFilterAnimator = UIViewPropertyAnimator(
        duration: ConstantsUI.STORY_LAYER_ANIMATION_DURATION,
        curve: .easeOut,
        animations: nil
    )

    var snapzoneInitialSize: CGSize {
        return snapzoneInitialFrame.size
    }

    var snapzoneSizeWithoutTransformation: CGSize {
        guard mode == .timeline else { return snapZoneView.frame.size }
        return getSnapzoneFrame(for: dimension).size
    }

    var defaultFont: BLFont? {
        return Model.default.fontManager.fonts().first { Model.default.fontManager.isFontReadyToUse($0, hardCheck: true) }
    }

    private(set) var controllerMediator: ControllerMediator!
    private(set) var mediaCreationService: MediaCreationService!
    private(set) var constraintButtonMenuInitialTrailing: CGFloat!
    private(set) var constraintButtonSearchInitialTrailing: CGFloat!
    private(set) var previewLongPressGesture: UILongPressGestureRecognizer!
    private(set) var keyboardHandler: ContentEditVCKeyboardHandler!
    private(set) var sharedMediaManager: SharedMediaManager!
    private(set) var subtitlesGenerator: SubtitleGenerator = AssemblySubtitleGenerator()
    private var layoutSetLaunchingState: LayoutSetState = .unknown
    private var noiseRemovalFileManager: LalalAINoiseRemovalFileManager = LalalAINoiseRemovalFileManager()

    // MARK: - Init

    deinit {
        print("\(type(of: self)) - \(#function)")
    }

    // MARK: - Lifecycle

    override var prefersStatusBarHidden: Bool {
        guard let window = AppDelegate.scene?.window else {
            if AppDelegate.scene?.window == nil {
                Logger.not_error(.generic, "AppDelegate.scene.window == nil")
            }
            return false
        }

        statusBarHidden = window.iPhoneRegular

        return statusBarHidden
    }

    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        _ = view
        let height = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width / 9 * 16)
        constraintSnapZoneHeight.constant = height
    }

    override func updateViewConstraints() {
        if layoutSetLaunchingState != .unknown {
            updateDimensionConstraints()
        }
        super.updateViewConstraints()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        VersionChecker.shared.showNewVersionAlertIfNeeded()

        styleUI()
        prepareUndoUI()
        keyboardHandler = ContentEditVCKeyboardHandler(
            constraintTextViewBottom: constraintTextViewBottom,
            textOptionsContainerViewBottomConstraint: textOptionsContainerViewBottomConstraint,
            textOptionsContainerViewHeightConstraint: textOptionsContainerViewHeightConstraint,
            snapView: snapZoneView
        )
        keyboardHandler?.delegate = self
        layoutPanel.delegate = self

        buttonTrash.alpha = 0
        buttonMenu.imageView!.contentMode = .scaleAspectFit

        constraintButtonMenuInitialTrailing = constraintButtonMenuTrailing.constant
        constraintButtonSearchInitialTrailing = constraintButtonSearchTrailing.constant

        controllerMediator = ControllerMediator(
            textAreaView: textAreaView,
            keyboardHandler: keyboardHandler,
            parent: self,
            mainView: view,
            dimView: textModeDimView,
            maxLayersView: maxLayersView,
            maxLayersViewOnTranslating: maxLayersViewOnTranslating,
            buttonTrash: buttonTrash,
            snapZoneView: snapZoneView,
            snapHintsView: snapHintsView,
            contentEditingActionPanel: contentEditingActionPanel
        )
        controllerMediator.delegate = self

        mediaCreationService = MediaCreationService(controllerMediator: controllerMediator)

        sharedMediaManager = SharedMediaManager(contentEditingViewController: self)

        textControllerCoordinator = TextControllerCoordinator(
            contentEditView: view,
            textModeDimView: textModeDimView,
            controllerMediator: controllerMediator,
            buttonSearch: buttonSearch,
            resetButton: buttonReset,
            textAreaView: textAreaView,
            textOptionsViewController: textOptionsViewController,
            textOptionsContainerViewHeightConstraint: textOptionsContainerViewHeightConstraint,
            textOptionsContainerView: textOptionsContainerView
        )
        if let defaultFont = defaultFont {
            textControllerCoordinator.addText(inText ?? "", with: defaultFont, id: UUID())
        }
        viewAssetsDuration.delegate = self
        viewAssetsDuration.controllerMediator = controllerMediator
        viewAssetsDuration.mediaCreationService = mediaCreationService
        setup()
        previewLongPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onPreview(_:)))
        view.addGestureRecognizer(previewLongPressGesture)

        contentEditingActionPanel.update(
            with: ContentEditingActionPanelItemFactory.createItems(controllerMediator: controllerMediator),
            delegate: self
        )
        contentEditingActionPanel.shareButton(isEnabled: controllerMediator.hasVisibleContentOnCanvas)
        scrubberView.show(controllerMediator.hasPlaybackOnCanvas)
        scrubberView.delegate = self

        if let gifURI = Bundle.main.url(forResource: "Equalizer", withExtension: "gif") {
            gifImageView.animate(withGIFURL: gifURI, loopCount: Int.max, preparationBlock: nil, animationBlock: nil)
        }
        setupDraftInterpretationManager()

        timelineView.delegate = self
        timelineView.controllerMediator = controllerMediator
        timelineView.mediaCreationService = mediaCreationService

        try? noiseRemovalFileManager.deleteAllTemporaryNoiseRemovedAudio()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Model.default.gifGeneratorManager.setPriority(dimension: dimension, types: .all)
        setupSynchronization(on: true)
        keyboardHandler!.viewWillAppear()
        calculateActionPanelHeight()

        if let text = inText, !text.isEmpty {
            viewBlur = UIVisualEffectViewAnimatable(effect: UIBlurEffect(style: .regular))
            view.addSubview(viewBlur!)
            viewBlur!.translatesAutoresizingMaskIntoConstraints = false
            viewBlur!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: viewBlur!.trailingAnchor).isActive = true
            viewBlur!.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: viewBlur!.bottomAnchor).isActive = true

            updateUI(.transforming, phase: .setup, initiator: nil)
        } else {
            controllerMediator.updateUI(.transforming, phase: .setup, initiator: nil)
        }
        configureLoadingView()
        setupPlaybackHandlers()
    }

    override func viewDidAppear(_ animated: Bool) {
        layoutSetLaunchingState = .set
        keyboardHandler.viewDidAppear()

        controllerMediator.resetLayouting()
        controllerMediator.viewDidLayoutSubviews()
        controllerMediator.viewDidAppear()

        onReady?()
        onReady = nil

        super.viewDidAppear(animated)

        if sharedMediaManager.isShareExtensionContentPending {
            sharedMediaManager.setupMediaFromShareExtension()
        }

        if sharedMediaManager.isExternalContentPending {
            sharedMediaManager.setupMediaFromIntegration()
        }
    }

    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)

        guard let title = textOptionsViewController.fontPickerView.collectionItems.first?.name else { return }

        updateFontCollectionsButtonUI(title: title)
        textOptionsViewController.fontPickerView.reload()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if snapzoneInitialFrame == nil {
            layoutSetLaunchingState = .set
            snapzoneInitialFrame = snapZoneView.frame
            view.setNeedsUpdateConstraints()
        }
        controllerMediator.viewDidLayoutSubviews()
    }

    override func viewWillDisappear(_ animated: Bool) {
        Model.default.gifGeneratorManager.resetPriority(dimension: dimension, types: .all)
        setupSynchronization(on: false)

        observers.forEach { NotificationCenter.default.removeObserver($0) }
        observers.removeAll()

        super.viewWillDisappear(animated)

        inText = textAreaView.text
        keyboardHandler.viewWillDisappear()
    }

    // MARK: - Public

    func onPreviewTransformMode(show: Bool) {
        contentEditingActionPanel.show(show)
        scrubberView.show(show && controllerMediator.hasPlaybackOnCanvas)
        labelInstruction.alpha = show ? 1 : 0
        buttonMenu.alpha = show ? 1 : 0
        buttonSearch.alpha = show ? 1 : 0
        buttonSound.alpha = show ? 1 : 0
        showUndoRedoContainer(show)

        guard let selectedSafeZoneOption = safezone?.safezoneOption,
              dimension == selectedSafeZoneOption.dimension else {
            safezone?.safeZoneViews.forEach {
                $0.safeZoneView.alpha = 0
                $0.gradientView?.alpha = 0
            }
            return
        }

        safezone?.safeZoneViews.forEach {
            $0.safeZoneView.alpha = show ? 0 : 1
            $0.gradientView?.alpha = show ? 0 : 1
        }
    }

    func updateInstructions() {
        let shouldBeHidden: Bool = controllerMediator.hasAnyContentAddedOnCanvas ? true : false
        if labelInstruction.isHidden != shouldBeHidden {
            labelInstruction.isHidden = shouldBeHidden
        }
    }

    func checkCollectionForActiveFont() {
        textOptionsViewController.fontPickerView.handleSelectedCollection()
        if let collectionItemName = textOptionsViewController.fontPickerView.selectedCollectionItem?.name {
            updateFontCollectionsButtonUI(title: collectionItemName)
        }
    }

    // MARK: - Actions

    @IBAction private func onTapTopBottomBlackView(_ sender: UITapGestureRecognizer) {
        guard layoutPanel.isShown else { return }
        onDeactivateLayout()
    }

    @IBAction private func onTapBackgroundView(_ sender: UITapGestureRecognizer) {
        let ptSnapzoneView = sender.location(in: snapZoneView)
        let insideSnapzone = snapZoneView.point(inside: ptSnapzoneView, with: nil)
        guard insideSnapzone else { return }

        let ptBottomBlackView = sender.location(in: contentEditingActionPanel.dimensionView)
        guard ptBottomBlackView.y < 0 else { return }

        guard layoutPanel.isShown else { return }
        onDeactivateLayout()
    }

    @IBAction private func onTapView(_ sender: UITapGestureRecognizer) {
        let ptSnapzoneView = sender.location(in: snapZoneView)
        let insideSnapzone = snapZoneView.point(inside: ptSnapzoneView, with: nil)
        guard insideSnapzone else { return }

        let ptBottomBlackView = sender.location(in: contentEditingActionPanel.dimensionView)
        guard ptBottomBlackView.y < 0,
              !isLoadingViewPresented else {
            return
        }

        textControllerCoordinator.editText()
        checkCollectionForActiveFont()
    }

    @IBAction func onDone() {
        controllerMediator.editText(false)
    }

    @IBAction private func onResetButtonTapped(_ sender: UIButton) {
        let title = "Reset Text"
        let message = "All text properties will be reset to default values."

        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        let resetAction = UIAlertAction(title: "Reset", style: .default) { [weak self] action in
            self?.resetTemplateText()
        }
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(resetAction)
        present(alertViewController, animated: true)
    }

    @IBAction private func didSwipeChevronView(_ sender: UISwipeGestureRecognizer) {
        prepareToOpenTimeline(openMethod: .swipe)
    }

    @IBAction private func didTapAllCollectons(_ sender: UIButton) {
        let collectionStoryboard = UIStoryboard(name: "Collections", bundle: nil)
        guard let collectionViewController = collectionStoryboard.instantiateInitialViewController() as? CollectionsViewController else { return }

        collectionViewController.modalPresentationStyle = .overFullScreen
        collectionViewController.collections = textOptionsViewController.fontPickerView.collectionItems
        collectionViewController.state = .fullScreen
        collectionViewController.type = .fonts
        collectionViewController.selectedCollection = textOptionsViewController.fontPickerView.selectedCollectionItem
        collectionViewController.onCollectionSelectedSubject
            .sink { [weak self] collectionItem in
                self?.textOptionsViewController.fontPickerView.selectedCollectionItem = collectionItem
                self?.updateFontCollectionsButtonUI(title: collectionItem.name)
            }
            .store(in: &subscriptions)
        present(collectionViewController, animated: true)
    }

    // MARK: - Private

    private func styleUI() {
        buttonTrash.layer.shadowOpacity = ConstantsUI.CELL_SHADOW_OPACITY
        buttonTrash.layer.shadowRadius = ConstantsUI.CELL_SHADOW_RADIUS
        buttonTrash.layer.shadowOffset = CGSize.zero
        buttonTrash.layer.shadowColor = #colorLiteral(red: 0.07843137255, green: 0.2705882353, blue: 0.6196078431, alpha: 0.15)
    }

    private func setup() {
        setupFilters()
        setupLayout()
        updateInstructions()
    }

    private func setupPlaybackHandlers() {
        controllerMediator.timelinePlayer.onUpdateFullPlaybackHandler = { [weak self] time in
            let mainDuration = self?.controllerMediator.timelinePlayer.mainItem?.timeRange.duration.seconds
            let itemsDuration = self?.controllerMediator.timelinePlayer.items.map { $0.timeRange.duration.seconds }.max()
            guard let duration = mainDuration ?? itemsDuration, duration > 0 else {
                return
            }
            self?.scrubberView.showPlaybackProgress(currentTime: time.seconds, duration: duration)
        }
        controllerMediator.timelinePlayer.onPlaybackStateUpdated = { [weak self] isPlaying in
            self?.scrubberView.setPlaybackState(isPlaying)
        }
    }

    private func calculateActionPanelHeight() {
        if let safeAreaBottomInset = AppDelegate.scene?.window?.safeAreaInsets.bottom,
           safeAreaBottomInset > 0,
           let safeAreaTopInset = AppDelegate.scene?.window?.safeAreaInsets.top {
            let snapZoneHeight = min(UIScreen.main.bounds.height, UIScreen.main.bounds.width / 9 * 16).rounded()
            let height = view.frame.maxY - safeAreaBottomInset - safeAreaTopInset - snapZoneHeight
            contentEditingActionPanelHeightConstraint.constant = height
        }
    }

    private func updateFontCollectionsButtonUI(title: String) {
        let width = calculateSelectedFontTitleViewWidth(title: title)
        collectionFontsButtonWidthConstraint.constant = width
        collectionFontsButton.setTitle(title, for: .normal)
        UIView.animate(withDuration: ConstantsUI.ANIMATION_DURATION) {
            self.collectionFontsContainerView.layoutIfNeeded()
        }
    }

    private func calculateSelectedFontTitleViewWidth(title: String) -> CGFloat {
        let font = UIFont(name: "Avenir-Medium", size: 14)
        let fontAttribute = [NSAttributedString.Key.font: font]
        let titleSize = title.size(withAttributes: fontAttribute as [NSAttributedString.Key: Any])
        let sideInset: CGFloat = 12.0
        let chevronWidth: CGFloat = 12.0
        let distanceToChevron: CGFloat = 4.0
        return (2 * sideInset) + titleSize.width + chevronWidth + distanceToChevron
    }

    private func resetTemplateText() {
        guard let activeTextController = controllerMediator.activeController as? TextLayerController,
              let templateInitialInfo = activeTextController.templateInitialInfo else {
            return
        }

        textAreaView.styledTextView.beginUpdates()
        if activeTextController.editable {
            activeTextController.updateText(templateInitialInfo.text)

            textOptionsViewController.refresh(activeFont: templateInitialInfo.font)
            activeTextController.update(
                font: templateInitialInfo.font,
                textEffectSettings: templateInitialInfo.textEffectSettings
            )

            textOptionsViewController.update(alignment: templateInitialInfo.textEffectSettings.textAlignment)

            textControllerCoordinator.activate(controller: activeTextController)
            activeTextController.removeHighlight()

            textControllerCoordinator.syncFontUI()

            activeTextController.update(
                font: templateInitialInfo.font,
                textEffectSettings: activeTextController.textEffectSettings
            )
        } else {
            activeTextController.updateText(templateInitialInfo.text)
            activeTextController.update(
                font: templateInitialInfo.font,
                textEffectSettings: activeTextController.textEffectSettings
            )
        }
        textAreaView.styledTextView.endUpdates()
    }

    @objc private func onPreview(_ gesture: UIGestureRecognizer) {
        var show = false

        switch gesture.state {
        case .began:
            show = false
        case .cancelled, .ended:
            show = true
        default:
            break
        }

        UIView.animate(withDuration: ConstantsUI.ANIMATION_DURATION) {
            switch self.mode {
            case .transforming:
                self.onPreviewTransformMode(show: show)
            case .textEditing, .assetDuration, .captions, .timeline:
                break
            case .layout:
                self.onPreviewLayoutMode(show: show)
            }
        }
    }
}
