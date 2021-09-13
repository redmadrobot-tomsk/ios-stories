//
//  StoryViewController.swift
//  Stories
//

import UIKit

private extension Constants {
  static let iPhone10ImageViewSidesRatio: Float = 16 / 9
}

protocol StoryViewControllerDelegate: AnyObject {
  func storyViewControllerDidFinish(_ viewController: StoryViewController)
  func storyViewControllerDidRequestToShowNextStory(_ viewController: StoryViewController)
  func storyViewControllerDidRequestToShowPreviousStory(_ viewController: StoryViewController)
}

class StoryViewController: UIViewController {
  // MARK: - Properties
  
  weak var delegate: StoryViewControllerDelegate?
  
  private let viewModel: StoryViewModelProtocol
  private let imageView = UIImageView()
  private let storyControlView = StoryControlView()
  private let topGradientView = UIView()
  private let bottomGradientView = UIView()
  private let contentView = StoryContentView()
  private let activityIndicatorView: ActivityIndicatorViewProtocol
  private let loadingErrorView: StoryErrorStateViewProtocol
  
  private var hasLoadingError: Bool = false

  var currentStoryPreviewImageURL: URL? {
    return viewModel.storyPreviewURL
  }
  
  // MARK: - Init
  
  init(viewModel: StoryViewModelProtocol) {
    self.viewModel = viewModel
    self.loadingErrorView = viewModel.componentsFactory.makeErrorStateView()
    self.activityIndicatorView = viewModel.componentsFactory.makeActivityIndicatorView()
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let startColor = viewModel.gradientStartColor, let endColor = viewModel.gradientEndColor {
      topGradientView.removeGradient()
      bottomGradientView.removeGradient()
      topGradientView.addGradient(startColor: startColor,
                                  endColor: endColor,
                                  startPoint: CGPoint(x: 0.5, y: 0),
                                  endPoint: CGPoint(x: 0.5, y: 1))
      bottomGradientView.addGradient(startColor: startColor,
                                     endColor: endColor,
                                     startPoint: CGPoint(x: 0.5, y: 1),
                                     endPoint: CGPoint(x: 0.5, y: 0))
    }
    
    configureForIPhone10()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    storyControlView.changeProgressBarState(.reset)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    configureAppearance(isReconfiguring: false)
    setupNotifications()
    bindViewModel()
  }
  
  // MARK: - Configure
  
  private func configure(isReconfiguring: Bool) {
    configureAppearance(isReconfiguring: isReconfiguring)
    configureContentView()
    if let gradient = viewModel.gradient {
      makeGradientViewsConstraints(for: gradient)
    }
    configureGradients()
  }
  
  private func reloadImageView() {
    configureAppearance(isReconfiguring: true)
    activityIndicatorView.startAnimating()

    loadingErrorView.isHidden = true
    hasLoadingError = false
    imageView.setImage(with: viewModel.currentImageURL) { [weak self] image, error in
      self?.activityIndicatorView.stopAnimating()
      guard self?.viewModel.shouldShowLoadingError == true else {
        self?.configureStoryAfterLoading(image: image)
        return
      }
      if let image = image {
        self?.configureStoryAfterLoading(image: image)
      } else {
        self?.configureAppearanceAfterLoading(hasError: true, error: error)
        self?.hasLoadingError = true
      }
    }
  }
  
  private func configureContentView(with storyContentViewModel: StoryContentViewModelProtocol,
                                    position: FrameContentPosition) {
    contentView.configure(with: storyContentViewModel)
    contentView.snp.remakeConstraints { make in
      make.trailing.leading.equalToSuperview().inset(viewModel.contentViewTrailingLeadingInset)
      switch position {
      case .bottom:
        make.bottom.equalTo(imageView).offset(viewModel.contentViewBottomOffset ?? 0)
      case .top:
        if viewModel.shouldConfigureForIPhone10, UIScreen.isIPhone10ScreenSizeOrHigher() {
          make.top.equalTo(imageView).offset(viewModel.iPhone10ContentViewTopOffset ?? 0)
        } else {
          make.top.equalTo(storyControlView.snp.bottom).offset(viewModel.contentViewTopOffset ?? 0)
        }
      }
    }
  }
  
  // MARK: Constraints
  
  private func makeGradientViewsConstraints(for gradient: StoryFrameGradient) {
    switch gradient {
    case .bottom:
      makeGradientConstraintsForBottomPosition()
    case .top:
      makeGradientConstraintsForTopPosition()
    case .both:
      makeGradientConstraintsForBothPositions()
    case .none:
      break
    }
  }
  
  // MARK: - Notifications
  
  private func setupNotifications() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(pauseAnimation),
                                           name: UIApplication.didEnterBackgroundNotification,
                                           object: nil)
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(resumeAnimation),
                                           name: UIApplication.willEnterForegroundNotification,
                                           object: nil)
  }
  
  // MARK: - View Model
  
  private func bindViewModel() {
    viewModel.onDidChangeFrameIndex = { [unowned self] in
      self.imageView.kf.cancelDownloadTask()
      self.activityIndicatorView.stopAnimating()
      self.start()
    }
    viewModel.onDidReachEndOfStory = { [unowned self] in
      self.showNextStory()
      self.storyControlView.updateProgressBarFrameIndex(with: self.viewModel.currentFrameIndex)
    }
    viewModel.onDidReachBeginOfStory = { [unowned self] in
      self.showPreviousStory()
    }
  }
  
  // MARK: - Setup
  
  private func setup() {
    view.backgroundColor = viewModel.backgroundColor
    setupImageView()
    setupTopGradientView()
    setupBottomGradientView()
    setupContentView()
    setupStoryControlView()
    setupLoadingErrorView()
    setupActivityIndicatorView()
    setupGestures()
    view.bringSubviewToFront(storyControlView)
  }
  
  private func setupImageView() {
    view.addSubview(imageView)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupTopGradientView() {
    topGradientView.backgroundColor = .clear
    view.addSubview(topGradientView)
  }
  
  private func setupBottomGradientView() {
    bottomGradientView.backgroundColor = .clear
    view.addSubview(bottomGradientView)
  }
  
  private func setupContentView() {
    view.addSubview(contentView)
    contentView.onDidTapActionButton = { [weak self] in
      guard let self = self else { return }
      if let url = URL(string: self.viewModel.frameActionURL) {
        UIApplication.shared.open(url)
      }
    }
  }
  
  private func setupStoryControlView() {
    view.addSubview(storyControlView)
    
    storyControlView.snp.makeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(viewModel.controlsViewTopOffset)
    }
    
    storyControlView.onDidTapLike = { [weak self] in
      self?.viewModel.toggleLike()
      let image = self?.viewModel.likeButtonImage
      self?.storyControlView.setLikeButtonImage(image: image)
    }
    storyControlView.onDidRequestToClose = { [weak self] in
      guard let self = self else { return }
      self.delegate?.storyViewControllerDidFinish(self)
    }
    storyControlView.onDidRequestToShowNextStory = { [weak self] in
      self?.showNextFrame()
    }
  }
  
  private func setupLoadingErrorView() {
    view.addSubview(loadingErrorView)
    loadingErrorView.isHidden = true
    loadingErrorView.onDidRequestToReload = { [weak self] in
      self?.reloadImageView()
    }
    loadingErrorView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupActivityIndicatorView() {
    view.addSubview(activityIndicatorView)
    activityIndicatorView.hidesWhenStopped = true
    activityIndicatorView.isHidden = true
    activityIndicatorView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  private func setupGestures() {
    let tapGestureChangeStory = UITapGestureRecognizer()
    tapGestureChangeStory.addTarget(self, action: #selector(didTapStory(_:)))
    tapGestureChangeStory.delegate = self
    tapGestureChangeStory.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGestureChangeStory)
    
    let longPressGesture = UILongPressGestureRecognizer()
    longPressGesture.cancelsTouchesInView = false
    longPressGesture.delegate = self
    longPressGesture.addTarget(self, action: #selector(didLongPressStory(_:)))
    view.addGestureRecognizer(longPressGesture)
    
    createSwipeGesture(withDirection: .left)
    createSwipeGesture(withDirection: .right)
  }
  
  private func createSwipeGesture(withDirection direction: UISwipeGestureRecognizer.Direction) {
    let swipeGesture = UISwipeGestureRecognizer()
    swipeGesture.cancelsTouchesInView = false
    swipeGesture.delegate = self
    swipeGesture.addTarget(self, action: #selector(didSwipeStory(_:)))
    swipeGesture.direction = direction
    view.addGestureRecognizer(swipeGesture)
  }
}

// MARK: - Actions

extension StoryViewController {
  @objc private func didLongPressStory(_ gestureRecognizer: UILongPressGestureRecognizer) {
    switch gestureRecognizer.state {
    case .began:
      setControlsVisibility(to: false)
      storyControlView.changeProgressBarState(.pause)
    case .cancelled, .ended, .failed:
      setControlsVisibility(to: true)
      storyControlView.changeProgressBarState(.resume)
    default:
      break
    }
  }
  
  @objc private func didSwipeStory(_ gestureRecognizer: UISwipeGestureRecognizer) {
    switch gestureRecognizer.direction {
    case .left:
      showNextStory()
    case .right:
      showPreviousStory()
    default:
      break
    }
  }
  
  @objc private func didTapStory(_ gestureRecognizer: UILongPressGestureRecognizer) {
    guard !hasLoadingError else { return }
    let location = gestureRecognizer.location(in: view)
    let percentOfWidth = location.x * 100.0 / view.bounds.width
    if percentOfWidth >= viewModel.borderOfChangeStoryInPercent {
      showNextFrame()
    } else {
      showPreviousFrame()
    }
  }
  
  @objc private func pauseAnimation() {
    if !hasLoadingError {
      storyControlView.changeProgressBarState(.pause)
    }
  }
  
  @objc private func resumeAnimation() {
    if !hasLoadingError {
      storyControlView.changeProgressBarState(.resume)
    }
  }
}

// MARK: - Public methods

extension StoryViewController {
  func start() {
    contentView.isHidden = true
    topGradientView.isHidden = true
    bottomGradientView.isHidden = true
    storyControlView.changeProgressBarState(.reset)
    reloadImageView()
  }

  func prepareForPresenting() {
    storyControlView.changeProgressBarState(.reset)
    reloadImageView()
  }
  
  func reset() {
    storyControlView.changeProgressBarState(.reset)
  }
  
  func pause() {
    storyControlView.changeProgressBarState(.pause)
  }
  
  func resume() {
    storyControlView.changeProgressBarState(.resume)
  }
}

// MARK: - Private methods

private extension StoryViewController {
  func setControlsVisibility(to isVisible: Bool) {
    storyControlView.setControlsVisibility(withAnimationDuration: viewModel.controlsAnimationDuration, isVisible: isVisible)
  }
  func showNextFrame() {
    viewModel.incrementCurrentFrameIndex()
  }
  func showPreviousFrame() {
    viewModel.decrementCurrentFrameIndex()
  }
  func showNextStory() {
    delegate?.storyViewControllerDidRequestToShowNextStory(self)
  }
  func showPreviousStory() {
    delegate?.storyViewControllerDidRequestToShowPreviousStory(self)
  }
  func configureForIPhone10() {
    guard viewModel.shouldConfigureForIPhone10, UIScreen.isIPhone10ScreenSizeOrHigher() else { return }
    imageView.layer.cornerRadius = viewModel.iPhone10ImageViewCornerRadius ?? 0
    imageView.snp.remakeConstraints { make in
      make.trailing.leading.equalToSuperview()
      make.height.equalTo(imageView.snp.width).multipliedBy(Constants.iPhone10ImageViewSidesRatio)
      make.top.equalToSuperview().offset(viewModel.iPhone10ImageViewTopOffset ?? 0)
    }
    storyControlView.snp.remakeConstraints { make in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().offset(viewModel.iPhone10StoryControlViewViewTopOffset ?? 0)
    }
  }
  func configureContentView() {
    guard let position = viewModel.currentContentPosition,
      let storyContentViewModel = viewModel.storyContentViewModel else {
        return
    }
    configureContentView(with: storyContentViewModel, position: position)
  }
  func configureAppearanceAfterLoading(hasError: Bool, error: NetworkError? = nil) {
    if hasError {
      imageView.backgroundColor = viewModel.imageViewErrorBackgroundColor
    }
    loadingErrorView.isHidden = !hasError
    if let error = error {
      loadingErrorView.configure(with: error)
    }
    contentView.isHidden = hasError
    bottomGradientView.isHidden = hasError
    topGradientView.isHidden = hasError
  }
  func configureStoryAfterLoading(image: UIImage?) {
    configureAppearanceAfterLoading(hasError: false)
    viewModel.setFrameShown()
    configure(isReconfiguring: true)
    if let image = image {
      imageView.image = image
    } else {
      imageView.backgroundColor = viewModel.imageViewErrorBackgroundColor
    }
    storyControlView.changeProgressBarState(.start(viewModel.storyFrameDuration))
  }
  func configureAppearance(isReconfiguring: Bool) {
    imageView.backgroundColor = viewModel.imageViewBackgroundColor
    storyControlView.configure(with: viewModel.storyControlViewModel)

    let trackColor: UIColor
    let progressColor: UIColor
    if viewModel.shouldConfigureForIPhone10,
      let iPhone10ProgressColor = viewModel.iPhone10ProgressColor,
      let iPhone10TrackColor = viewModel.iPhone10TrackColor {
      trackColor = iPhone10TrackColor
      progressColor = iPhone10ProgressColor
    } else {
      trackColor = viewModel.trackColor
      progressColor = viewModel.progressColor
    }
    storyControlView.configureProgressBar(viewModel: viewModel,
                                          isReconfiguring: isReconfiguring,
                                          trackColor: trackColor,
                                          progressColor: progressColor,
                                          spacing: viewModel.progressViewSpacing)
  }
  func configureGradients() {
    guard let gradient = viewModel.gradient else { return }
    switch gradient {
    case .bottom:
      bottomGradientView.isHidden = false
      topGradientView.isHidden = true
    case .top:
      bottomGradientView.isHidden = true
      topGradientView.isHidden = false
    case .both:
      bottomGradientView.isHidden = false
      topGradientView.isHidden = false
    case .none:
      bottomGradientView.isHidden = true
      topGradientView.isHidden = true
    }
  }
  func makeGradientConstraintsForTopPosition() {
    if UIScreen.isIPhone10ScreenSizeOrHigher(), viewModel.shouldConfigureForIPhone10 {
      topGradientView.snp.remakeConstraints { make in
        make.top.equalTo(imageView)
        make.leading.trailing.equalToSuperview()
        make.bottom.equalTo(contentView).offset(viewModel.topGradientOffset)
      }
    } else {
      topGradientView.snp.remakeConstraints { make in
        make.top.leading.trailing.equalToSuperview()
        make.bottom.equalTo(contentView).offset(viewModel.topGradientOffset)
      }
    }
  }
  func makeGradientConstraintsForBothPositions() {
    if UIScreen.isIPhone10ScreenSizeOrHigher(), viewModel.shouldConfigureForIPhone10 {
      topGradientView.snp.remakeConstraints { make in
        make.top.equalTo(imageView)
        make.leading.trailing.equalToSuperview()
        make.bottom.equalTo(imageView.snp.centerY).offset(viewModel.topGradientOffset)
      }
      bottomGradientView.snp.remakeConstraints { make in
        make.trailing.leading.equalToSuperview()
        make.bottom.equalTo(imageView)
        make.top.equalTo(topGradientView.snp.bottom).offset(viewModel.bottomGradientOffset)
      }
    } else {
      topGradientView.snp.remakeConstraints { make in
        make.top.leading.trailing.equalToSuperview()
        make.bottom.equalTo(imageView.snp.centerY).offset(viewModel.topGradientOffset)
      }
      bottomGradientView.snp.remakeConstraints { make in
        make.trailing.leading.bottom.equalToSuperview()
        make.top.equalTo(topGradientView.snp.bottom).offset(viewModel.bottomGradientOffset)
      }
    }
  }
  func makeGradientConstraintsForBottomPosition() {
    if UIScreen.isIPhone10ScreenSizeOrHigher(), viewModel.shouldConfigureForIPhone10 {
      bottomGradientView.snp.remakeConstraints { make in
        make.trailing.leading.equalToSuperview()
        make.bottom.equalTo(imageView)
        make.top.equalTo(contentView).offset(viewModel.bottomGradientOffset)
      }
    } else {
      bottomGradientView.snp.remakeConstraints { make in
        make.trailing.leading.bottom.equalToSuperview()
        make.top.equalTo(contentView).offset(viewModel.bottomGradientOffset)
      }
    }
  }
}

// MARK: - UIGestureRecognizerDelegate

extension StoryViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                         shouldReceive touch: UITouch) -> Bool {
    return !(touch.view?.isKind(of: UIButton.self) ?? true)
  }
}
