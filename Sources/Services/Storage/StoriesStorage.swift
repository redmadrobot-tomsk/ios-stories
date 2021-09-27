//
//  StoriesStorage.swift
//  Stories
//

import Foundation

class StoriesStorage: StoriesStoring {
  // MARK: - Properties
  
  var configuration: StorageConfiguration {
    return (try? configurationStorage.object(forKey: Keys.configuration)) ?? .default
  }
  
  private let storiesStorage = Storage<StoryStoreOptions>()
  private let indexesStorage = Storage<[String]>()
  private let configurationStorage = Storage<StorageConfiguration>()
  
  private var subscribers: [Subscriber] = []
  
  private(set) lazy var configurator = StorageConfigurator(storage: self)
  
  private struct Keys {
    static let configuration = "configuration"
  }
  
  private enum IndexKey: String {
    case allStories
  }
  
  // MARK: - Init
  
  init() {
    clearConfiguration()
  }
  
  // MARK: - Public methods
  
  func add(_ story: Story, lifetime: TimeInterval? = nil) throws {
    let index = UUID().uuidString
    let storyStoreOptions = StoryStoreOptions(story: story, index: index,
                                              lifetime: lifetime ?? configuration.storiesLifetime)
    try storiesStorage.setObject(storyStoreOptions, forKey: index)
    try addIndex(index)
    
    prefetchImagesIfNeeded(story: story)
    
    notify()
  }
  
  func add(_ stories: [Story], lifetime: TimeInterval? = nil) throws {
    var indexes: [String] = []
    
    try stories.forEach { story in
      let index = UUID().uuidString
      let storyStoreOptions = StoryStoreOptions(story: story, index: index,
                                                lifetime: lifetime ?? configuration.storiesLifetime)
      try storiesStorage.setObject(storyStoreOptions, forKey: index)
      indexes.append(index)
      
      prefetchImagesIfNeeded(story: story)
    }
    
    try addIndexes(indexes)
    
    notify()
  }
  
  func replace(with stories: [Story], lifetime: TimeInterval? = nil) throws {
    try clear()
    try add(stories, lifetime: lifetime)
    
    notify()
  }
  
  func createOrUpdate(with stories: [Story], lifetime: TimeInterval? = nil) throws {
    try stories.forEach { story in
      if var storyStoreOptions = try getStoredStoriesWithOptions().filter({ $0.story == story }).first {
        storyStoreOptions.story = story
        storyStoreOptions.lifetime = lifetime ?? configuration.storiesLifetime
        try storiesStorage.setObject(storyStoreOptions, forKey: storyStoreOptions.index)
      } else {
        try add(story, lifetime: lifetime)
      }
    }
  }
  
  func delete(_ story: Story) throws {
    try delete { $0.story == story }
  }
  
  func delete(where predicate: (_ storyOptions: StoryStoreOptions) -> Bool) throws {
    var indexes = getIndexes()
    try indexes.forEach { index in
      let storyOptions = try storiesStorage.object(forKey: index)
      if predicate(storyOptions) {
        try storiesStorage.remove(forKey: index)
        indexes.removeAll { $0 == index }
        removeCache(story: storyOptions.story)
      }
    }
    try setIndexes(indexes)
    
    notify()
  }
  
  func clear() throws {
    try? getStories().forEach { removeCache(story: $0) }
    
    try storiesStorage.clearAllData()
    try indexesStorage.clearAllData()
    
    notify()
  }
  
  func getStories() throws -> [Story] {
    return try getStoredStoriesWithOptions().map { $0.story }
  }
  
  func getStories(where predicate: (_ storyOptions: StoryStoreOptions) -> Bool) throws -> [Story] {
    return try getStoredStoriesWithOptions().filter(predicate).map { $0.story }
  }
  
  func getValidStories(lifetime: TimeInterval? = nil) throws -> [Story] {
    if let lifetime = lifetime {
      return try getStories { $0.createdAt.addingTimeInterval(lifetime) > Date() }
    } else {
      return try getStories { $0.expirationDate > Date() }
    }
  }
  
  func getSeenStories() throws -> [Story] {
    return try getStories { $0.story.isSeen }
  }
  
  func getNotSeenStories() throws -> [Story] {
    return try getStories { !$0.story.isSeen }
  }
  
  func setStorySeenState(story: Story, isSeen: Bool) throws {
    var stories = try getStories()
    if let index = stories.firstIndex(of: story) {
      stories[index].isSeen = isSeen
    }
    try createOrUpdate(with: stories)
    
    notify()
  }
  
  // MARK: - Internal methods
  
  func setConfiguration(_ configuration: StorageConfiguration) {
    try? configurationStorage.setObject(configuration, forKey: Keys.configuration)
  }
  
  func clearConfiguration() {
    try? configurationStorage.remove(forKey: Keys.configuration)
  }
  
  func notify() {
    subscribers.forEach { $0.update() }
  }
  
  // MARK: - Private methods
  
  private func getStoredStoriesWithOptions() throws -> [StoryStoreOptions] {
    updateStorage()
    
    let indexes = getIndexes()
    return try indexes.map {
      return try storiesStorage.object(forKey: $0)
    }.sorted(by: sortStoriesComparator)
  }
  
  private func sortStoriesComparator(firstStoryOptions: StoryStoreOptions,
                                     secondStoryOptions: StoryStoreOptions) -> Bool {
    for (index, type) in configuration.sortType.enumerated() {
      let comparator: (AnyComparable, AnyComparable) -> Bool
      let order = configuration.sortOrder.element(at: index) ?? configuration.sortOrder.last ?? .asc
      
      switch order {
      case .asc:
        comparator = (<)
      case .desc:
        comparator = (>)
      }
      
      let lhs: AnyComparable
      let rhs: AnyComparable
      
      switch type {
      case .date:
        lhs = AnyComparable(firstStoryOptions.createdAt)
        rhs = AnyComparable(secondStoryOptions.createdAt)
      case .seen:
        lhs = AnyComparable(firstStoryOptions.story.isSeen.intValue)
        rhs = AnyComparable(secondStoryOptions.story.isSeen.intValue)
      }
      
      if lhs == rhs {
        continue
      } else {
        return comparator(lhs, rhs)
      }
    }
    
    return false
  }
  
  // MARK: - Indexes
  
  private func getIndexes(key: IndexKey = .allStories) -> [String] {
    return (try? indexesStorage.object(forKey: key.rawValue)) ?? []
  }
  
  private func setIndexes(_ indexes: [String], key: IndexKey = .allStories) throws {
    try indexesStorage.setObject(indexes, forKey: key.rawValue)
  }
  
  private func addIndex(_ index: String) throws {
    var indexes = getIndexes()
    indexes.append(index)
    try setIndexes(indexes)
  }
  
  private func addIndexes(_ indexes: [String]) throws {
    var storedIndexes = getIndexes()
    storedIndexes.append(contentsOf: indexes)
    try setIndexes(storedIndexes)
  }
  
  // MARK: - Storage jobs
  
  private func updateStorage() {
    if configuration.deleteExpiredStories {
      try? deleteOldStories()
    }
  }
  
  private func deleteOldStories() throws {
    var indexes = getIndexes()
    
    try indexes.forEach { index in
      let storyOptions = try storiesStorage.object(forKey: index)
      if storyOptions.expirationDate < Date() {
        try storiesStorage.remove(forKey: index)
        indexes.removeAll { $0 == index }
        removeCache(story: storyOptions.story)
      }
    }
    
    try setIndexes(indexes)
  }
  
  private func prefetchImagesIfNeeded(story: Story) {
    guard configuration.prefetchImages else { return }
    
    ImageDownloadUtility.cacheImage(with: story.imageURL)
    story.frames.forEach { frame in
      ImageDownloadUtility.cacheImage(with: frame.imageURL)
    }
  }
  
  private func removeCache(story: Story) {
    ImageDownloadUtility.removeImageCache(for: story.imageURL)
    story.frames.forEach { frame in
      ImageDownloadUtility.removeImageCache(for: frame.imageURL)
    }
  }
}

// MARK: - Publisher

extension StoriesStorage: Publisher {
  func subscribe(_ subscriber: Subscriber) {
    subscribers.append(subscriber)
  }
  
  func unsubscribe(_ subscriber: Subscriber) {
    subscribers.removeAll { $0 === subscriber }
  }
}
