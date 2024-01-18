//
//  StoryViewModel.swift
//  Stories
//

import UIKit

private extension Constants {
  private static let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
  static let topSafeAreaInset: CGFloat = windowScene?.windows.first?.safeAreaInsets.top ?? 0
  static let bottomSafeAreaInset: CGFloat = windowScene?.windows.first?.safeAreaInsets.bottom ?? 0
}

class StoryViewModel: StoryViewModelProtocol {
  // MARK: - Properties
  
  var topGradientOffset: CGFloat = 50
  var bottomGradientOffset: CGFloat = -50
  var gradientStartColor: UIColor? {
    let alpha = story.frames.element(at: currentFrameIndex)?.content.gradientStartAlpha ?? 0.7
    let color = story.frames.element(at: currentFrameIndex)?.content.gradientColor ?? .black
    return color.withAlphaComponent(alpha)
  }
  var gradientEndColor: UIColor? {
    let color = story.frames.element(at: currentFrameIndex)?.content.gradientColor ?? .black
    return color.withAlphaComponent(0)
  }
  
  var activityIndicatorStyle: UIActivityIndicatorView.Style
  var activityIndicatorColor: UIColor
  var storyFrameDuration: TimeInterval = 7
  var controlsAnimationDuration: TimeInterval = 0.2
  
  var storyContentViewModel: StoryContentViewModelProtocol? {
    guard let frame = currentFrame else { return nil }
    return StoryContentViewModel(frame: frame, componentsFactory: componentsFactory)
  }
  var storyControlViewModel: StoryControlViewModelProtocol {
    guard currentFrame != nil else { return StoryControlViewModel(colorMode: colorMode) }
    return StoryControlViewModel(colorMode: colorMode)
  }
  var storyLoadingErrorViewModel: StoryLoadingErrorViewModelProtocol
  var shouldShowLoadingError: Bool = true
  
  var contentViewTrailingLeadingInset: CGFloat = 16
  var contentViewBottomOffset: CGFloat? = -(Constants.bottomSafeAreaInset + 24)
  var contentViewTopOffset: CGFloat? = 29
  
  var controlsViewTopOffset: CGFloat =  max(Constants.topSafeAreaInset, 32)
  
  var loadingErrorViewConstraints = ViewConstraintsContainer(leadingOffset: 16,
                                                                    trailingOffset: -16,
                                                                    centerYOffset: 0)
  
  var shouldConfigureForIPhone10: Bool = false
  var iPhone10ImageViewCornerRadius: CGFloat? = 8
  var iPhone10ImageViewTopOffset: CGFloat? = 116
  var iPhone10StoryControlViewViewTopOffset: CGFloat? = 52
  var iPhone10ContentViewTopOffset: CGFloat? = 24
  var iPhone10TrackColor: UIColor?
  var iPhone10ProgressColor: UIColor?
  
  var currentImageURL: URL? { return story.frames.element(at: currentFrameIndex)?.imageURL }
  var storyPreviewURL: URL? { return story.imageURL }
  var currentContentPosition: FrameContentPosition? {
    return story.frames.element(at: currentFrameIndex)?.content.position
  }
  var framesCount: Int { return story.frames.count }
  
  var likeButtonImage: UIImage? { return story.isLiked ? likedIcon : notLikedIcon }
  var likedIcon: UIImage? = nil
  var notLikedIcon: UIImage? = nil
  var frameActionURL: String { return currentFrame?.content.action?.urlString ?? "" }
  
  var imageViewBackgroundColor: UIColor
  var imageViewErrorBackgroundColor: UIColor = .black
  
  var backgroundColor: UIColor = .black
  
  var trackColor: UIColor {
    guard let frame = currentFrame else { return UIColor.white.withAlphaComponent(0.2) }
    switch frame.content.controlsColorMode {
    case .dark:
      return UIColor.black.withAlphaComponent(0.2)
    case .light:
      return UIColor.white.withAlphaComponent(0.2)
    }
  }
  
  var progressColor: UIColor {
    guard let frame = currentFrame else { return UIColor.white.withAlphaComponent(0.7) }
    switch frame.content.controlsColorMode {
    case .dark:
      return UIColor.black.withAlphaComponent(0.7)
    case .light:
      return UIColor.white.withAlphaComponent(0.7)
    }
  }
  
  var progressViewSpacing: CGFloat = 4
  
  var onDidReachEndOfStory: (() -> Void)?
  var onDidReachBeginOfStory: (() -> Void)?
  var onDidChangeFrameIndex: (() -> Void)?
  var onDidSetFrameShown: (() -> Void)?
  var onDidLikeStory: ((Bool) -> Void)?
  
  var gradient: StoryFrameGradient? { return currentFrame?.content.gradient }
  var borderOfChangeStoryInPercent: CGFloat = 30
  var currentFrameIndex: Int = 0
  
  let componentsFactory: StoriesUIComponentsFactory
  
  private var story: Story
  private var currentFrame: StoryFrame? { return story.frames.element(at: currentFrameIndex) }
  private var colorMode: FrameControlsColorMode { return currentFrame?.content.controlsColorMode ?? .light }
  
  // MARK: - Init
  
  init(story: Story, componentsFactory: StoriesUIComponentsFactory) {
    self.story = story
    self.componentsFactory = componentsFactory
    
    let currentFrame = story.frames.element(at: currentFrameIndex)
    let colorMode = currentFrame?.content.controlsColorMode ?? .light
    storyLoadingErrorViewModel = StoryLoadingErrorViewModel(offlineTitle: "Error",
                                                            offlineSubtitle: "Error occurred",
                                                            serverErrorTitle: "Error",
                                                            serverErrorSubtitle: "Error occurred",
                                                            refreshButtonTitle: "Refresh")
    
    let lightModeColor: UIColor = .white
    let trackAlpha: CGFloat = 0.2
    let progressAlpha: CGFloat = 0.7
    let lightModeTrackColor = lightModeColor.withAlphaComponent(trackAlpha)
    let lightModeProgressColor = lightModeColor.withAlphaComponent(progressAlpha)
    
    iPhone10TrackColor = lightModeTrackColor
    iPhone10ProgressColor = lightModeProgressColor
    
    switch colorMode {
    case .dark:
      activityIndicatorStyle = .medium
      activityIndicatorColor = .white
      imageViewBackgroundColor = .white
    case .light:
      activityIndicatorStyle = .medium
      activityIndicatorColor = .lightGray
      imageViewBackgroundColor = .black
    }
  }
  
  // MARK: - Methods
  
  func toggleLike() {
    story.isLiked.toggle()
    onDidLikeStory?(story.isLiked)
  }
  
  func setFrameShown() {
    guard currentFrameIndex >= 0, currentFrameIndex < story.frames.count else { return }
    story.frames[currentFrameIndex].isAlreadyShown = true
    onDidSetFrameShown?()
  }
  
  private func progressBarColor(for colorMode: FrameControlsColorMode) -> UIColor {
    switch colorMode {
    case .dark:
      return .black
    case .light:
      return .white
    }
  }
  
  private func progressColor(for colorMode: FrameControlsColorMode) -> UIColor {
    return progressBarColor(for: colorMode).withAlphaComponent(0.7)
  }
  
  private func trackColor(for colorMode: FrameControlsColorMode) -> UIColor {
    return progressBarColor(for: colorMode).withAlphaComponent(0.2)
  }
}
