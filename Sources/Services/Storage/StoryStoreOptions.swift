//
//  StoryStoreOptions.swift
//  Stories
//

import Foundation

/// Structure with additional storing info.
public struct StoryStoreOptions: Codable {
  /// `Story`, saved in storage.
  var story: Story
  /// Unique item key.
  let index: String
  /// Period while story is valid. Story deletes automatically after this interval.
  var lifetime: TimeInterval
  /// A `Date` when record was created in storage.
  let createdAt: Date
  
  /// A `Date` when story will be deleted. Calculated as `createdAt + lifetime`.
  var expirationDate: Date {
    return createdAt.addingTimeInterval(lifetime)
  }
  
  init(story: Story, index: String, lifetime: TimeInterval = .infinity,
       createdAt: Date = Date()) {
    self.story = story
    self.index = index
    self.lifetime = lifetime
    self.createdAt = createdAt
  }
}
