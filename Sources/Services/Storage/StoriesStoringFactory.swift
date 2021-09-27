//
//  StoriesStoringFactory.swift
//  Stories
//

import Foundation

/// Object, that creates stories storage.
public struct StoriesStoringFactory {
  private static let storiesStorage = StoriesStorage()
  
  /// Returns default stories storage.
  ///
  /// - Returns: Storage object, that conforms `StoriesStoring` protocol.
  public static func defaultStorage() -> StoriesStoring {
    return storiesStorage
  }
  
  static func defaultPublishingStorage() -> StoriesStoring & Publisher {
    return storiesStorage
  }
}
