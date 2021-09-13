//
//  DefaultStoriesDataSource.swift
//  Stories
//

import UIKit

class DefaultStoriesDataSource: StoriesListViewDataSource {
  // MARK: - Properties
  
  var customConfiguration: StorageConfiguration?
  
  private let storiesStorage = StoriesStoringFactory.defaultPublishingStorage()
  
  private var stories: [Story] = []
  private var storiesListView: StoriesListView?
  
  private var configuration: StorageConfiguration {
    return customConfiguration ?? storiesStorage.configuration
  }
  
  // MARK: - Init
  
  init() {
    storiesStorage.subscribe(self)
    reload()
  }
  
  deinit {
    storiesStorage.unsubscribe(self)
  }
  
  // MARK: - Public methods
  
  func setup(with storiesListView: StoriesListView) {
    self.storiesListView = storiesListView
  }
  
  func reload() {
    self.stories = getStories()
    storiesListView?.reloadData()
  }
  
  func didShowStory(at index: Int) {
    guard let story = stories.element(at: index) else { return }
    try? storiesStorage.setStorySeenState(story: story, isSeen: true)
  }
  
  func storiesListView(_ storiesListView: StoriesListView, storyForItemAt index: Int) -> Story? {
    return stories.element(at: index)
  }
  
  func numberOfStories(_ storiesListView: StoriesListView) -> Int {
    return stories.count
  }
  
  // MARK: - Private methods
  
  private func getStories() -> [Story] {
    switch configuration.showStoriesOption {
    case .valid:
      return (try? storiesStorage.getValidStories(lifetime: customConfiguration?.storiesLifetime)) ?? []
    case .all:
        return (try? storiesStorage.getStories()) ?? []
    case .seen:
      return (try? storiesStorage.getSeenStories()) ?? []
    case .notSeen:
      return (try? storiesStorage.getNotSeenStories()) ?? []
    }
  }
}

// MARK: - Subscriber

extension DefaultStoriesDataSource: Subscriber {
  func update() {
    reload()
  }
}
