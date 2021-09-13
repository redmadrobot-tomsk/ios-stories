//
//  StoriesStoring.swift
//  Stories
//

import Foundation

/// A type that defines a number of methods to work with stories storage
public protocol StoriesStoring {
  /// Current storage configuration
  var configuration: StorageConfiguration { get }
  
  /// A strage configurator object
  var configurator: StorageConfigurator { get }
  
  /// Adds new story to existing (or empty) stories into the storage.
  ///
  /// - Parameter story: `Story` model that will be saved into the storage.
  /// - Parameter lifetime: A `TimeInterval` while story is valid.
  ///
  /// - Throws: Any `Error` produced during writing to the storage.
  func add(_ story: Story, lifetime: TimeInterval?) throws
  
  /// Adds multiple stories to existing (or empty) stories into the storage.
  ///
  /// - Parameter stories: An array of `Story` models that will be saved into the storage.
  /// - Parameter lifetime: A `TimeInterval` while story is valid.
  ///
  /// - Throws: Any `Error` produced during the writing to the storage.
  func add(_ stories: [Story], lifetime: TimeInterval?) throws
  
  /// Replaces all existing stories in the storage with given or adds them if the storage is empty.
  ///
  /// - Parameter stories: An array of `Story` models that will replace existing.
  /// - Parameter lifetime: A `TimeInterval` while story is valid.
  ///
  /// - Throws: Any `Error` produced during the writing to the storage.
  func replace(with stories: [Story], lifetime: TimeInterval?) throws
  
  /// Updates existing stories in the storage with the given stories and creates the new one if story isn't stored.
  ///
  /// - Parameter stories: An array of `Story` models that will update existing.
  /// - Parameter lifetime: A `TimeInterval` while story is valid.
  ///
  /// - Throws: Any `Error` produced during writing to the storage.
  func createOrUpdate(with stories: [Story], lifetime: TimeInterval?) throws
  
  /// Deletes given story from the storage.
  ///
  /// - Parameter story: A `Story` that will be deleted.
  ///
  /// - Throws: Any `Error` produced during writing to the storage.
  func delete(_ story: Story) throws
  
  /// Deletes stories in the storage that conform to the given condition.
  ///
  /// - Parameter predicate: A closure, that accepts a `Story` and returns `true` if
  ///                         the story should be deleted or `false` if shouldn't.
  /// - Parameter storyOptions: A `StoryStoreOptions` structure, containing story and additional parameters.
  ///
  /// - Throws: Any `Error` produced during writing to the storage.
  func delete(where predicate: (_ storyOptions: StoryStoreOptions) -> Bool) throws
  
  /// Deletes all data in the storage.
  ///
  /// - Throws: Any `Error` produced during writing to the storage.
  func clear() throws
  
  /// Returns all stories saved in the storage.
  ///
  /// - Returns: An array of `Story` from the storage.
  /// - Throws: Any `Error` produced during writing to the storage.
  func getStories() throws -> [Story]
  
  /// Returns stories from the storage that conforms to the given condition.
  ///
  /// - Parameter predicate: A closure, that accepts a `Story` and returns `true` if
  ///                        the story should be included into result and `false` if shouldn't.
  /// - Parameter storyOptions: A `StoryStoreOptions` structure, containing story and additional parameters.
  ///
  /// - Returns: An array of `Story` from the storage, selected by given condition.
  /// - Throws: Any `Error` produced during writing to the storage.
  func getStories(where predicate: (_ storyOptions: StoryStoreOptions) -> Bool) throws -> [Story]
  
  /// Returns not expired stories.
  ///
  /// - Parameter lifetime: Custom `Story` validity period.
  ///
  /// - Returns: An array of `Story` from the storage that not expired,
  /// - Throws: Any `Error` produced during writing to the storage.
  func getValidStories(lifetime: TimeInterval?) throws -> [Story]
  
  /// Returns stories seen by user.
  ///
  /// - Returns: An array of `Story` from the storage that were viewed by user.
  /// - Throws: Any `Error` produced during writing to the storage.
  func getSeenStories() throws -> [Story]
  
  /// Returns not seen stories.
  ///
  /// - Returns: An array of `Story` from the storage that weren't viewed by user.
  /// - Throws: Any `Error` produced during writing to the storage.
  func getNotSeenStories() throws -> [Story]
  
  /// Updates `isSeen` parameter of a `Story`.
  ///
  /// - Parameter story: Story that should be updated.
  /// - Parameter isSeen: New value for `isSeen` property.
  ///
  /// - Throws: Any `Error` produced during writing to the storage.
  func setStorySeenState(story: Story, isSeen: Bool) throws
}

public extension StoriesStoring {
  /// Adds new story to existing (or empty) stories into the storage.
  ///
  /// - Parameter story: `Story` model that will be saved into the storage.
  /// - Parameter lifetime: A `TimeInterval` while story is valid.
  ///
  /// - Throws: Any `Error` produced during writing to the storage.
  func add(_ story: Story, lifetime: TimeInterval? = nil) throws {
    try add(story, lifetime: lifetime)
  }
  
  /// Adds multiple stories to existing (or empty) stories into the storage.
  ///
  /// - Parameter stories: An array of `Story` models that will be saved into the storage.
  /// - Parameter lifetime: A `TimeInterval` while story is valid.
  ///
  /// - Throws: Any `Error` produced during the writing to the storage.
  func add(_ stories: [Story], lifetime: TimeInterval? = nil) throws {
    try add(stories, lifetime: lifetime)
  }
  
  /// Replaces all existing stories in the storage with given or adds them if the storage is empty.
  ///
  /// - Parameter stories: An array of `Story` models that will replace existing.
  /// - Parameter lifetime: A `TimeInterval` while story is valid.
  ///
  /// - Throws: Any `Error` produced during the writing to the storage.
  func replace(with stories: [Story], lifetime: TimeInterval? = nil) throws {
    try replace(with: stories, lifetime: lifetime)
  }
  
  /// Updates existing stories in the storage with the given stories and creates the new one if story isn't stored.
  ///
  /// - Parameter stories: An array of `Story` models that will update existing.
  /// - Parameter lifetime: A `TimeInterval` while story is valid.
  ///
  /// - Throws: Any `Error` produced during writing to the storage.
  func createOrUpdate(with stories: [Story], lifetime: TimeInterval? = nil) throws {
    try createOrUpdate(with: stories, lifetime: nil)
  }
  
  /// Returns not expired stories.
  ///
  /// - Parameter lifetime: Custom `Story` validity period.
  ///
  /// - Returns: An array of `Story` from the storage that not expired,
  /// - Throws: Any `Error` produced during writing to the storage.
  func getValidStories(lifetime: TimeInterval? = nil) throws -> [Story] {
    try getValidStories(lifetime: lifetime)
  }
}
