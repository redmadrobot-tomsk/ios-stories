//
//  StorageConfigurator.swift
//  Stories
//

import Foundation

public class StorageConfigurator {
  // MARK: - Properties
  
  private let storage: StoriesStorage
  
  // MARK: - Init
  
  init(storage: StoriesStorage) {
    self.storage = storage
  }
  
  // MARK: - Public methods
  
  /// Sets period while stories will be valid. Stories will be deleted after given interval.
  ///
  /// - Parameter lifetime: Interval while stories will be valid.
  ///
  /// - Returns: `StorageConfigurator` object.
  @discardableResult
  public func setStoriesLifetime(_ lifetime: TimeInterval) -> StorageConfigurator {
    updateConfiguration { configuration in
      configuration.storiesLifetime = lifetime
    }
    return self
  }
  
  /// Sets by wich field stories shold be sorted.
  ///
  /// - Parameter type: A `StoriesSortType` that defines field to sort by.
  ///
  /// - Returns: `StorageConfiguratior` object.
  @discardableResult
  public func orderBy(_ type: StoriesSortType) -> StorageConfigurator {
    updateConfiguration { configuration in
      configuration.sortType = [type]
    }
    return self
  }
  
  /// Sets by wich fields stories shold be sorted.
  /// You can pass array of fields to sort by from the first prioroty to the last.
  /// If stories is equal by some field, it whould be compared by the next one.
  ///
  /// - Parameter types: An array of `StoriesSortType` that defines fields to sort by according to the given order.
  ///
  /// - Returns: `StorageConfiguratior` object.
  @discardableResult
  public func orderBy(_ types: [StoriesSortType]) -> StorageConfigurator {
    updateConfiguration { configuration in
      configuration.sortType = types
    }
    return self
  }
  
  /// Sets sorting direction.
  ///
  /// - Parameter direction: A `SortOrder` that describes the direction – `forward` or `reverse`.
  ///
  /// - Returns: `StorageConfiguratior` object.
  @discardableResult
  public func orderDirection(_ direction: SortOrder) -> StorageConfigurator {
    updateConfiguration { configuration in
      configuration.sortOrder = [direction]
    }
    return self
  }
  
  /// Sets sorting directions. You can pass an array of directions so each field from passed sorting fields will be sorted according to it's direction.
  /// If a count of directions is less then a count of fileds, the last direction will be used.
  ///
  /// - Parameter directions: An array`SortOrder` that describes the direction of it's field – `forward` or `reverse`.
  ///
  /// - Returns: `StorageConfiguratior` object.
  @discardableResult
  public func orderDirection(_ directions: [SortOrder]) -> StorageConfigurator {
    updateConfiguration { configuration in
      configuration.sortOrder = directions
    }
    return self
  }
  
  /// Sets if expired stories should be deleted or not.
  ///
  /// - Parameter shouldDelete: Set `true` if stories should be deleted or `false` if not.
  ///
  /// - Returns: `StorageConfiguratior` object.
  @discardableResult
  public func deleteExpiredStories(_ shouldDelete: Bool) -> StorageConfigurator {
    updateConfiguration { configuration in
      configuration.deleteExpiredStories = shouldDelete
    }
    return self
  }
  
  /// Sets which stories shoild be shown.
  ///
  /// - Parameter showOption: A `ShowStoriesOption`, defining stories that should be shown.
  ///
  /// - Returns: `StorageConfiguratior` object.
  @discardableResult
  public func show(_ showOption: ShowStoriesOption) -> StorageConfigurator {
    updateConfiguration { configuration in
      configuration.showStoriesOption = showOption
    }
    return self
  }
  
  /// Sets if images should be downloaded before user viewed a story.
  ///
  /// - Parameter shouldPrefetch: Set `true` if images should be downloaded beforehand or `false` if not.
  ///
  /// - Returns: `StorageConfiguratior` object.
  @discardableResult
  public func prefetchImages(_ shouldPrefetch: Bool) -> StorageConfigurator {
    updateConfiguration { configuration in
      configuration.prefetchImages = shouldPrefetch
    }
    return self
  }
  
  /// Reloads views with new configuration.
  ///
  /// - Returns: `StorageConfiguratior` object.
  @discardableResult
  public func reload() -> StorageConfigurator {
    storage.notify()
    return self
  }
  
  // MARK: - Private methods
  
  private func updateConfiguration(block: (inout StorageConfiguration) -> Void) {
    var configuration = storage.configuration
    block(&configuration)
    storage.setConfiguration(configuration)
  }
}
