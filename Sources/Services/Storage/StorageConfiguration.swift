//
//  StorageConfiguration.swift
//  Stories
//

import Foundation

/// Defines the field to sort by,
public enum StoriesSortType: String, Codable {
  case date, seen
}

/// Defines stories showing options
public enum ShowStoriesOption: String, Codable {
  /// Show all stories from the storage.
  case all
  /// Show stories which lifetime hasn't expired.
  case valid
  /// Show stories that user have already seen.
  case seen
  /// Show stories that user haven't seen.
  case notSeen
}

/// Storage configuration object.
public struct StorageConfiguration: Codable {
  /// Period while stories are actual.
  public var storiesLifetime: TimeInterval
  /// Field to sort stories by.
  public var sortType: [StoriesSortType]
  /// Sorting direction.
  public var sortOrder: [SortOrder]
  /// Defines if expired stories should be deleted.
  public var deleteExpiredStories: Bool
  /// Defines which stories should be shown.
  public var showStoriesOption: ShowStoriesOption
  /// Defines if images should be downloaded before user viewed the story.
  public var prefetchImages: Bool
  
  public init(storiesLifetime: TimeInterval? = nil, showStoriesOption: ShowStoriesOption? = nil) {
    let defaultConfiguration = StorageConfiguration.default
    self = defaultConfiguration
    self.storiesLifetime = storiesLifetime ?? defaultConfiguration.storiesLifetime
    self.showStoriesOption = showStoriesOption ?? defaultConfiguration.showStoriesOption
  }
  
  internal init(storiesLifetime: TimeInterval, sortType: [StoriesSortType], sortOrder: [SortOrder],
                deleteExpiredStories: Bool, showStoriesOption: ShowStoriesOption, prefetchImages: Bool) {
    self.storiesLifetime = storiesLifetime
    self.sortType = sortType
    self.sortOrder = sortOrder
    self.deleteExpiredStories = deleteExpiredStories
    self.showStoriesOption = showStoriesOption
    self.prefetchImages = prefetchImages
  }
  
  /// Default stories' storage configuration
  public static var `default`: StorageConfiguration {
    return StorageConfiguration(storiesLifetime: .infinity, sortType: [.seen, .date],
                                sortOrder: [.forward, .reverse], deleteExpiredStories: false,
                                showStoriesOption: .valid, prefetchImages: false)
  }
}
