//
//  StoriesListView.swift
//  Stories
//

import UIKit
import Kingfisher

public protocol StoriesListViewDataSource {
  var customConfiguration: StorageConfiguration? { get set }
  func setup(with storiesListView: StoriesListView)
  func reload()
  func didShowStory(at index: Int)
  func numberOfStories(_ storiesListView: StoriesListView) -> Int
  func storiesListView(_ storiesListView: StoriesListView, storyForItemAt index: Int) -> Story?
}

public extension StoriesListViewDataSource {
  func storiesListView(_ storiesListView: StoriesListView, sizeForItemAt index: Int) -> CGSize {
    return Constants.defaultStoriesListCellSize
  }
}

public class StoriesListView: UIView {
  /// View controller that contains `StoriesListView` and presents stories
  public var presentingViewController: UIViewController? {
    didSet {
      setupStories()
    }
  }
  
  /// Object that creates UI components for customizable views.
  public var uiComponentsFactory: StoriesUIComponentsFactory = StoriesUIComponentsFactory() {
    didSet {
      let cellClass = uiComponentsFactory.storiesListCellType()
      collectionView.register(cellClass.self, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }
  }
  
  /// Spacing between story preview cells in horizontal list.
  public var spacing: CGFloat {
    get {
      layout.minimumLineSpacing
    }
    set {
      layout.minimumLineSpacing = newValue
    }
  }
  
  /// Left and right insets of stories list, spacing between left side of view and the first cell, right side of view and the last cell.
  public var horizontalInset: CGFloat {
    get {
      layout.sectionInset.left
    }
    set {
      layout.sectionInset = UIEdgeInsets(top: 0, left: newValue, bottom: 0, right: newValue)
    }
  }
  
  /// Overrides global storage configuration.
  public var customConfiguration: StorageConfiguration? {
    get {
      return dataSource.customConfiguration
    }
    set {
      dataSource.customConfiguration = newValue
    }
  }
  
  public override var intrinsicContentSize: CGSize {
    return CGSize(width: super.intrinsicContentSize.width, height: height)
  }
  
  let transitionAnimator: TransitionAnimator = TransitionAnimator()
  
  private var height: CGFloat
  private var cellClass: StoriesListCell.Type {
    return uiComponentsFactory.storiesListCellType()
  }
  
  private(set) var dataSource: StoriesListViewDataSource
  
  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
  
  private let layout = StoriesListViewFlowLayout()
  
  // MARK: - Init
  
  /// Initializes and returns a newly allocated stories list view object.
  /// - Parameter height: Height of stories list view to calculate intrinsic content size.
  /// - Parameter dataSource: Object, that provides data for stories list view.
  public init(height: CGFloat? = nil, dataSource: StoriesListViewDataSource? = nil) {
    self.dataSource = dataSource ?? DefaultStoriesDataSource()
    self.height = height ?? Constants.defaultStoriesListCellSize.height
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  /// Reloads stories in list.
  public func reload() {
    dataSource.reload()
  }
  
  func reloadData() {
    collectionView.reloadData()
  }
  
  // MARK: - Setup
  
  private func setup() {
    addSubview(collectionView)
    
    collectionView.dataSource = self
    collectionView.delegate = self
    
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.backgroundColor = .clear
    collectionView.clipsToBounds = false
    collectionView.register(cellClass.self, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    
    dataSource.setup(with: self)
    
    collectionView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
}

// MARK: - UICollectionViewDataSource

extension StoriesListView: UICollectionViewDataSource {
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.numberOfStories(self)
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let story = dataSource.storiesListView(self, storyForItemAt: indexPath.row) else {
      fatalError("No story for item at index \(indexPath.row) was returned from data source")
    }
    
    // TODO: - Move prefetching to stories storage in future
    if let imageURL = story.frames.first?.imageURL {
      KingfisherManager.shared.retrieveImage(with: imageURL, completionHandler: nil)
    }
    
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath)
            as? StoriesListCell else {
      fatalError("Registred cellClass is not StoriesListCell")
    }
    cell.configure(with: story)
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StoriesListView: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {
    return cellClass.cellSize
  }
  
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var stories: [Story] = []
    var imageOptions: [Int: StoriesListCellImageOptions] = [:]
    
    // TODO: - Made stories in StoryContainerViewController loading from data source
    for index in 0..<dataSource.numberOfStories(self) {
      if let story = dataSource.storiesListView(self, storyForItemAt: index) {
        stories.append(story)
      }
    }
    
    collectionView.indexPathsForVisibleItems.forEach { indexPath in
      if let cell = (collectionView.cellForItem(at: indexPath) as? StoriesListCell),
         let presentingViewController = presentingViewController {
        let convertedFrame = self.convert(cell.imageFrame, from: cell)
        imageOptions[indexPath.item] = StoriesListCellImageOptions(frame: presentingViewController.view.convert(convertedFrame, from: self),
                                                                   cornerRadius: cell.imageView.layer.cornerRadius,
                                                                   maskedCorners: cell.imageView.layer.maskedCorners)
      }
    }
    
    showStories(stories: stories, storyIndex: indexPath.row, visibleStoryImageOptions: imageOptions)
  }
}

// MARK: - StoriesShowing

extension StoriesListView: StoriesShowing {
  func storiesContainerViewController(_ viewController: StoriesContainerViewController,
                                      didFinishWithFinalStoryImageURL imageURL: URL?,
                                      destinationStoryImageOptions imageOptions: StoriesListCellImageOptions?) {
    transitionAnimator.storiesDismissAnimationController = StoriesDismissAnimationController(storyImageOptions: imageOptions,
                                                                                             imageURL: imageURL)
    presentingViewController?.dismiss(animated: true, completion: nil)
  }

  func storiesContainerViewController(_ viewController: StoriesContainerViewController,
                                      didChangeCurrentStoryIndexTo index: Int) {
    currentStoryIndexDidChange(to: index)
  }
  
  func storiesContainerViewController(_ viewController: StoriesContainerViewController, didShowStoryWithIndex index: Int) {
    dataSource.didShowStory(at: index)
  }
  
  func storiesContainerViewControllerWillAppear(_ viewController: StoriesContainerViewController) {}
  func storiesContainerViewControllerWillDisappear(_ viewController: StoriesContainerViewController) {}
}
