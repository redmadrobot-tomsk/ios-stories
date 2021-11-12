//
//  StoryViewModelProtocol.swift
//  Stories
//

import UIKit

protocol StoryViewModelProtocol: AnyObject {
  var storyFrameDuration: TimeInterval { get set }
  var controlsAnimationDuration: TimeInterval { get set }
  var borderOfChangeStoryInPercent: CGFloat { get set }
  
  var storyContentViewModel: StoryContentViewModelProtocol? { get }
  var storyControlViewModel: StoryControlViewModelProtocol { get }
  var storyLoadingErrorViewModel: StoryLoadingErrorViewModelProtocol { get set }
  var shouldShowLoadingError: Bool { get set }
  
  var contentViewTrailingLeadingInset: CGFloat { get set }
  var contentViewBottomOffset: CGFloat? { get set }
  var contentViewTopOffset: CGFloat? { get set }
  
  var controlsViewTopOffset: CGFloat { get set }
  
  var loadingErrorViewConstraints: ViewConstraintsContainer { get set }
  
  var shouldConfigureForIPhone10: Bool { get set }
  var iPhone10ImageViewCornerRadius: CGFloat? { get set }
  var iPhone10ImageViewTopOffset: CGFloat? { get set }
  var iPhone10StoryControlViewViewTopOffset: CGFloat? { get set }
  var iPhone10ContentViewTopOffset: CGFloat? { get set }
  var iPhone10TrackColor: UIColor? { get set }
  var iPhone10ProgressColor: UIColor? { get set }
  
  var currentImageURL: URL? { get }
  var storyPreviewURL: URL? { get }
  var currentContentPosition: FrameContentPosition? { get }
  var framesCount: Int { get }
  var likeButtonImage: UIImage? { get }
  var likedIcon: UIImage? { get set }
  var notLikedIcon: UIImage? { get set }
  var frameActionURL: String { get }
  var imageViewBackgroundColor: UIColor { get set }
  var imageViewErrorBackgroundColor: UIColor { get set }
  
  var backgroundColor: UIColor { get set }
  
  var trackColor: UIColor { get }
  var progressColor: UIColor { get }
  var progressViewSpacing: CGFloat { get set }
  
  var onDidReachEndOfStory: (() -> Void)? { get set }
  var onDidReachBeginOfStory: (() -> Void)? { get set }
  var onDidChangeFrameIndex: (() -> Void)? { get set }
  var onDidLikeStory: ((_ isLiked: Bool) -> Void)? { get set }
  var onDidSetFrameShown: (() -> Void)? { get set }
  
  var gradient: StoryFrameGradient? { get }
  
  var topGradientOffset: CGFloat { get set }
  var bottomGradientOffset: CGFloat { get set }
  var gradientStartColor: UIColor? { get }
  var gradientEndColor: UIColor? { get }
  
  var activityIndicatorStyle: UIActivityIndicatorView.Style { get set }
  var activityIndicatorColor: UIColor { get set }
  
  var currentFrameIndex: Int { get set }
  
  var componentsFactory: StoriesUIComponentsFactory { get }
  
  func incrementCurrentFrameIndex()
  func decrementCurrentFrameIndex()
  func toggleLike()
  func setFrameShown()
}

extension StoryViewModelProtocol {
  var topGradientOffset: CGFloat {
    0
  }
  var bottomGradientOffset: CGFloat {
    0
  }
  var gradientStartColor: UIColor? {
    nil
  }
  var gradientEndColor: UIColor? {
    nil
  }
  var activityIndicatorStyle: UIActivityIndicatorView.Style {
    .medium
  }
  var activityIndicatorColor: UIColor {
    .white
  }
  
  func incrementCurrentFrameIndex() {
    if currentFrameIndex == framesCount - 1 {
      onDidReachEndOfStory?()
    } else {
      currentFrameIndex += 1
      onDidChangeFrameIndex?()
    }
  }
  
  func decrementCurrentFrameIndex() {
    if currentFrameIndex == 0 {
      onDidReachBeginOfStory?()
    } else {
      currentFrameIndex -= 1
      onDidChangeFrameIndex?()
    }
  }
}
