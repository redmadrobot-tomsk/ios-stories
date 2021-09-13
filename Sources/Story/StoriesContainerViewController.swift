//
//  StoriesContainerViewController.swift
//  Stories
//

import UIKit

protocol StoriesContainerViewControllerDelegate: AnyObject {
  func storiesContainerViewController(_ viewController: StoriesContainerViewController,
                                      didFinishWithFinalStoryImageURL imageURL: URL?,
                                      destinationStoryImageOptions imageOptions: StoriesListCellImageOptions?)
  func storiesContainerViewControllerWillAppear(_ viewController: StoriesContainerViewController)
  func storiesContainerViewControllerWillDisappear(_ viewController: StoriesContainerViewController)
  func storiesContainerViewController(_ viewController: StoriesContainerViewController, didChangeCurrentStoryIndexTo index: Int)
  func storiesContainerViewController(_ viewController: StoriesContainerViewController, didShowStoryWithIndex index: Int)
}

class StoriesContainerViewController: UIViewController {
  // MARK: - Properties
  
  override var prefersStatusBarHidden: Bool {
    return true
  }
  
  weak var delegate: StoriesContainerViewControllerDelegate?
  
  private let storyViewControllers: [StoryViewController]
  private let scrollView = UIScrollView()
  private let stackView = UIStackView()
  
  private var visibleStoryImageOptions: [Int: StoriesListCellImageOptions]
  private var currentStoryIndex: Int {
    didSet {
      delegate?.storiesContainerViewController(self, didChangeCurrentStoryIndexTo: self.currentStoryIndex)
    }
  }
  private var childContainers: [UIView] = []
  private var viewAppearedAtLeastOnce: Bool = false
  
  private var screenWidth: CGFloat {
    return UIScreen.main.bounds.width
  }
  
  private var contentOffset: CGPoint {
    return CGPoint(x: screenWidth * CGFloat(currentStoryIndex), y: 0)
  }
  
  // MARK: - Init
  
  init(childViewControllers: [StoryViewController], currentStoryIndex: Int,
       visibleStoryImageOptions: [Int: StoriesListCellImageOptions]) {
    self.storyViewControllers = childViewControllers
    self.currentStoryIndex = currentStoryIndex
    self.visibleStoryImageOptions = visibleStoryImageOptions
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    delegate?.storiesContainerViewControllerWillAppear(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    delegate?.storiesContainerViewControllerWillDisappear(self)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    if !viewAppearedAtLeastOnce {
      storyViewControllers.element(at: currentStoryIndex)?.start()
      delegate?.storiesContainerViewController(self, didShowStoryWithIndex: currentStoryIndex)
    }
    viewAppearedAtLeastOnce = true
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if let currentContainer = childContainers.element(at: currentStoryIndex) {
      scrollView.setContentOffset(currentContainer.frame.origin, animated: false)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupScrollView()
    setupStackView()
    setupStoryViewControllers()
    
    UIApplication.shared.isIdleTimerDisabled = true
  }
  
  func prepareForPresenting() {
    storyViewControllers.element(at: currentStoryIndex)?.prepareForPresenting()
  }
  
  func pause() {
    storyViewControllers.forEach { $0.pause() }
  }
  
  func resume() {
    storyViewControllers.forEach { $0.resume() }
  }
  
  func close() {
    if let viewController = storyViewControllers.element(at: currentStoryIndex) {
      finish(currentStoryImageURL: viewController.currentStoryPreviewImageURL)
    }
  }
  
  // MARK: - Setup
  
  func setupScrollView() {
    view.addSubview(scrollView)
    scrollView.delegate = self
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.isPagingEnabled = true
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupStackView() {
    scrollView.addSubview(stackView)
    stackView.axis = .horizontal
    stackView.snp.makeConstraints { make in
      make.top.bottom.equalTo(view)
      make.trailing.leading.equalToSuperview()
    }
  }
  
  private func setupStoryViewControllers() {
    for viewController in storyViewControllers {
      let childContainer = UIView()
      childContainers.append(childContainer)
      stackView.addArrangedSubview(childContainer)
      childContainer.snp.makeConstraints { make in
        make.width.equalTo(view)
      }
      addChildViewController(viewController, to: childContainer)
      viewController.delegate = self
    }
  }
}

// MARK: - Private Methods

private extension StoriesContainerViewController {
  func addChildViewController(_ viewController: UIViewController, to view: UIView) {
    guard viewController.view.superview == nil else { return }
    addChild(viewController)
    view.addSubview(viewController.view)
    viewController.view.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    viewController.didMove(toParent: self)
  }
  
  func showNextStory(for viewController: StoryViewController) {
    guard currentStoryIndex != childContainers.count - 1 else {
      finish(currentStoryImageURL: viewController.currentStoryPreviewImageURL)
      return
    }
    
    viewController.reset()
    currentStoryIndex += 1
    scrollView.setContentOffset(contentOffset, animated: true)
    startCurrentStory()
  }
  
  func showPreviousStory(for viewController: StoryViewController) {
    guard currentStoryIndex != 0 else {
      startCurrentStory()
      return
    }
    
    viewController.reset()
    currentStoryIndex -= 1
    scrollView.setContentOffset(contentOffset, animated: true)
    startCurrentStory()
  }
  
  func finish(currentStoryImageURL imageURL: URL?) {
    UIApplication.shared.isIdleTimerDisabled = false
    let imageOptions = visibleStoryImageOptions[currentStoryIndex]
    delegate?.storiesContainerViewController(self, didFinishWithFinalStoryImageURL: imageURL,
                                             destinationStoryImageOptions: imageOptions)
  }
  
  func startCurrentStory() {
    guard viewAppearedAtLeastOnce else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      self.storyViewControllers.element(at: self.currentStoryIndex)?.start()
      self.delegate?.storiesContainerViewController(self, didShowStoryWithIndex: self.currentStoryIndex)
    }
  }
}

// MARK: - UIScrollViewDelegate

extension StoriesContainerViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    storyViewControllers.element(at: currentStoryIndex)?.reset()
    currentStoryIndex = Int(scrollView.contentOffset.x / screenWidth)
    storyViewControllers.element(at: currentStoryIndex)?.start()
    delegate?.storiesContainerViewController(self, didShowStoryWithIndex: currentStoryIndex)
  }
  
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    storyViewControllers.element(at: currentStoryIndex)?.pause()
  }
}

// MARK: - StoryViewControllerDelegate

extension StoriesContainerViewController: StoryViewControllerDelegate {
  func storyViewControllerDidFinish(_ viewController: StoryViewController) {
    finish(currentStoryImageURL: viewController.currentStoryPreviewImageURL)
  }
  
  func storyViewControllerDidRequestToShowNextStory(_ viewController: StoryViewController) {
    showNextStory(for: viewController)
  }
  
  func storyViewControllerDidRequestToShowPreviousStory(_ viewController: StoryViewController) {
    showPreviousStory(for: viewController)
  }
}
