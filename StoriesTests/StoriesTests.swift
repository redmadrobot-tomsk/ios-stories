//
//  StoriesTests.swift
//  StoriesTests
//

import XCTest
import Kingfisher
@testable import Stories

class StoriesTests: XCTestCase {
  private var storage: StoriesStorage!
  
  override func setUp() {
    storage = StoriesStorage()
  }
  
  // MARK: - Test configurator
  
  func testConfiguratorSortTypePropertyUpdatesForSingle() throws {
    let property: StoriesSortType = .date
    
    storage.configurator.orderBy(property)
    
    XCTAssertEqual(storage.configuration.sortType, [property], "Sort type property doesn't update")
  }
  
  func testConfiguratorSortTypePropertyUpdatesForMultiple() throws {
    let properties: [StoriesSortType] = [.date, .seen]
    
    storage.configurator.orderBy(properties)
    
    XCTAssertEqual(storage.configuration.sortType, properties, "Sort type property doesn't update")
  }
  
  func testConfiguratorSortOrderPropertyUpdatesForSingle() throws {
    let direction: SortOrder = .forward
    
    storage.configurator.orderDirection(direction)
    
    XCTAssertEqual(storage.configuration.sortOrder, [direction], "Sort order property doesn't update")
  }
  
  func testConfiguratorSortOrderPropertyUpdatesForMultiple() throws {
    let directions: [SortOrder] = [.reverse, .forward]
    
    storage.configurator.orderDirection(directions)
    
    XCTAssertEqual(storage.configuration.sortOrder, directions, "Sort order property doesn't update")
  }
  
  func testConfiguratorPrefetchImagesPropertyUpdates() throws {
    let shouldPrefetch = true
    
    storage.configurator.prefetchImages(shouldPrefetch)
    
    XCTAssertEqual(storage.configuration.prefetchImages, shouldPrefetch, "Prefetch images property doesn't update")
  }
  
  func testConfiguratorDeleteExpiredStoriesPropertyUpdates() throws {
    let shouldDelete = true
    
    storage.configurator.deleteExpiredStories(shouldDelete)
    
    XCTAssertEqual(storage.configuration.deleteExpiredStories, shouldDelete, "Delete expired stories property doesn't update")
  }
  
  func testConfiguratorStoriesLifetimePropertyUpdates() throws {
    let lifetime: TimeInterval = 60 * 60 * 24 * 7
    
    storage.configurator.setStoriesLifetime(lifetime)
    
    XCTAssertEqual(storage.configuration.storiesLifetime, lifetime, "Stories lifetime property doesn't update")
  }
  
  func testConfiguratorShowStoriesOptionPropertyUpdates() throws {
    let showStoriesOption: ShowStoriesOption = .notSeen
    
    storage.configurator.show(showStoriesOption)
    
    XCTAssertEqual(storage.configuration.showStoriesOption, showStoriesOption, "Show stories option property doesn't update")
  }
  
  func testConfiguratorReloadCalledSubscribersUpdate() throws {
    let mockSubscriber = MockSubscriber()
    storage.subscribe(mockSubscriber)
    
    storage.configurator.reload()
    
    XCTAssertTrue(mockSubscriber.hasCalledUpdate, "Subscriber's update wasn't called")
  }
  
  // MARK: - Test storage
  
  func testStorageAddsSingleStoryToEmptyStorage() throws {
    storage.configurator.orderBy(.date).orderDirection(.forward)
    try storage.clear()
    let story = fakeStories()[0]
    
    try storage.add(story)
    let storedStories = try storage.getStories()
    
    XCTAssertEqual(storedStories, [story], "Storage doesn't add a single story")
  }
  
  func testStorageAddsSingleStoryToExistingStories() throws {
    storage.configurator.orderBy(.date).orderDirection(.forward)
    let stories = fakeStories()
    let firstStory = stories[0]
    let secondStory = stories[1]
    try storage.replace(with: [firstStory])
    
    try storage.add(secondStory)
    let storedStories = try storage.getStories()
    
    XCTAssertEqual(storedStories, [firstStory, secondStory], "Storage doesn't add a single story")
  }
  
  func testStorageAddsSingleStoryWithCustomLifetime() throws {
    let story = fakeStories()[0]
    storage.configurator.setStoriesLifetime(10)
    try storage.clear()
    
    try storage.add(story, lifetime: 1)
    
    let lifetimeExpectation = expectation(description: "Wait for stories lifetime expiring")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      let validStories = try? self?.storage.getValidStories()
      let allStories = try? self?.storage.getStories()
      XCTAssertEqual(validStories?.count, 0, "Storage doesn't set custom lifetime")
      XCTAssertEqual(allStories, [story], "Storage doesn't save story")
      lifetimeExpectation.fulfill()
    }
    
    wait(for: [lifetimeExpectation], timeout: 5)
  }
  
  func testStorageAddsMultipleStoriesToEmptyStorage() throws {
    storage.configurator.orderBy(.date).orderDirection(.forward)
    try storage.clear()
    let stories = fakeStories()
    
    try storage.add(stories)
    let storedStories = try storage.getStories()
    
    XCTAssertEqual(storedStories, stories, "Storage doesn't add multiple stories")
  }
  
  func testStorageAddsMultipleStoriesToExistingStories() throws {
    storage.configurator.orderBy(.date).orderDirection(.forward)
    let stories = fakeStories()
    let firstStories = Array(stories[0...2])
    let secondStories = Array(stories[3...5])
    try storage.replace(with: firstStories)
    
    try storage.add(secondStories)
    let storedStories = try storage.getStories()
    
    XCTAssertEqual(storedStories, stories, "Storage doesn't add multiple stories")
  }
  
  func testStorageAddsMultipleStoryWithCustomLifetime() throws {
    let stories = fakeStories()
    storage.configurator.setStoriesLifetime(10).orderBy(.date)
    try storage.clear()
    
    try storage.add(stories, lifetime: 1)
    
    let lifetimeExpectation = expectation(description: "Wait for stories lifetime expiring")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      let validStories = try? self?.storage.getValidStories()
      let allStories = try? self?.storage.getStories()
      XCTAssertEqual(validStories?.count, 0, "Storage doesn't set custom lifetime")
      XCTAssertEqual(allStories, stories, "Storage doesn't save stories")
      lifetimeExpectation.fulfill()
    }
    
    wait(for: [lifetimeExpectation], timeout: 5)
  }
  
  func testStorageReplacesStories() throws {
    storage.configurator.orderBy(.date).orderDirection(.forward)
    let stories = fakeStories()
    let firstStories = Array(stories[0...2])
    let secondStories = Array(stories[3...5])
    try storage.clear()
    try storage.add(firstStories)
    
    try storage.replace(with: secondStories)
    let storedStories = try storage.getStories()
    
    XCTAssertEqual(storedStories, secondStories, "Storage doesn't replace stories")
  }
  
  func testStorageReplacesStoriesWithCustomLifetime() throws {
    storage.configurator.setStoriesLifetime(10).orderBy(.date)
    let stories = fakeStories()
    let firstStories = Array(stories[0...2])
    let secondStories = Array(stories[3...5])
    try storage.clear()
    try storage.add(firstStories)
    
    try storage.replace(with: secondStories, lifetime: 1)
    
    let lifetimeExpectation = expectation(description: "Wait for stories lifetime expiring")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      let validStories = try? self?.storage.getValidStories()
      let allStories = try? self?.storage.getStories()
      XCTAssertEqual(validStories?.count, 0, "Storage doesn't set custom lifetime")
      XCTAssertEqual(allStories, secondStories, "Storage doesn't replace stories")
      lifetimeExpectation.fulfill()
    }
    
    wait(for: [lifetimeExpectation], timeout: 5)
  }
  
  func testStorageCreatesOrUpdatesStories() throws {
    storage.configurator.orderBy(.date).setStoriesLifetime(1)
    try storage.clear()
    let stories = fakeStories()
    let firstStories = Array(stories[0...2])
    let newStory = stories[3]
    try storage.add(firstStories)
    
    let lifetimeExpectation = expectation(description: "Wait for stories lifetime expiring")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      var newStories = firstStories + [newStory]
      for (index, story) in newStories.enumerated() {
        var editedStory = story
        editedStory.isSeen = true
        newStories[index] = editedStory
      }
      try? self?.storage.createOrUpdate(with: newStories)
      
      let storedStories = try? self?.storage.getStories()
      let validStories = try? self?.storage.getValidStories()
      storedStories?.forEach { XCTAssertTrue($0.isSeen, "Storage doesn't create or update stories") }
      XCTAssertEqual(storedStories, newStories, "Storage doesn't create or update stories")
      XCTAssertEqual(validStories?.count, 1, "Storage doesn't create or update stories")
      lifetimeExpectation.fulfill()
    }
    
    wait(for: [lifetimeExpectation], timeout: 5)
  }
  
  func testStorageCreatesOrUpdatesStoriesWithCustomLifetime() throws {
    storage.configurator.orderBy(.date).setStoriesLifetime(1)
    try storage.clear()
    let stories = fakeStories()
    let firstStories = Array(stories[0...2])
    let newStory = stories[3]
    try storage.add(firstStories)
    
    let lifetimeExpectation = expectation(description: "Wait for stories lifetime expiring")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      var newStories = firstStories + [newStory]
      for (index, story) in newStories.enumerated() {
        var editedStory = story
        editedStory.isSeen = true
        newStories[index] = editedStory
      }
      try? self?.storage.createOrUpdate(with: newStories, lifetime: 2)
      
      let storedStories = try? self?.storage.getStories()
      storedStories?.forEach { XCTAssertTrue($0.isSeen, "Storage doesn't create or update stories") }
      XCTAssertEqual(storedStories, newStories, "Storage doesn't create or update stories")
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
        let validStories = try? self?.storage.getValidStories()
        XCTAssertEqual(validStories?.count, 1, "Storage doesn't create or update stories")
        lifetimeExpectation.fulfill()
      }
    }
    
    wait(for: [lifetimeExpectation], timeout: 5)
  }
  
  func testClearDeletesAllStories() throws {
    try storage.add(fakeStories())
    
    try storage.clear()
    let stories = try storage.getStories()
    
    XCTAssertEqual(stories.count, 0, "Clear method doesn't delete stories")
  }
  
  func testStorageDeletesStory() throws {
    let stories = fakeStories()
    let storyToDelete = stories[1]
    try storage.replace(with: stories)
    
    try storage.delete(storyToDelete)
    let storedStories = try storage.getStories()
    
    XCTAssertNil(storedStories.firstIndex(of: storyToDelete), "Delete method doesn't delete story")
  }
  
  func testStorageDeletesStoriesByGivenCondition() throws {
    let stories = fakeStories()
    try storage.replace(with: stories)
    
    try storage.delete { $0.story.isSeen == true }
    let storedStories = try storage.getStories()
    
    XCTAssertEqual(storedStories, stories.filter { !$0.isSeen }, "Delete(where:) method doesn't delete stories")
  }
  
  func testStorageDeletesExpiredStories() throws {
    storage.configurator.deleteExpiredStories(true)
    try storage.replace(with: fakeStories(), lifetime: 1)
    
    let lifetimeExpectation = expectation(description: "Wait for stories lifetime expiring")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      let stories = try? self?.storage.getStories()
      XCTAssertEqual(stories?.count, 0, "Storage doesn't delete expired stories")
      lifetimeExpectation.fulfill()
    }
    
    wait(for: [lifetimeExpectation], timeout: 5)
  }
  
  func testStorageReturnsAllStories() throws {
    storage.configurator.orderBy(.date)
    try storage.clear()
    let stories = fakeStories()
    try storage.add(stories)
    
    let storedStories = try storage.getStories()
    
    XCTAssertEqual(storedStories, stories, "Storage doesn't return stories")
  }
  
  func testStorageSortsStoriesBySeenDesc() throws {
    let stories = fakeStories()
    storage.configurator.orderBy(.seen).orderDirection(.reverse)
    try storage.clear()
    try storage.add(stories)
    
    let storedStories = try storage.getStories()
    let sortedStories = stories.sorted { $0.isSeen.intValue > $1.isSeen.intValue }
    
    XCTAssertEqual(storedStories, sortedStories, "Storage doesn't sort stories")
  }
  
  func testStorageSortsStoriesByDateDesc() throws {
    let stories = fakeStories()
    let firstStories = Array(stories[0...2])
    let secondStories = Array(stories[3...5])
    storage.configurator.orderBy(.date).orderDirection(.reverse)
    try storage.clear()
    try storage.add(firstStories)
    
    let delayExpectation = expectation(description: "Stories add delay")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      try? self?.storage.add(secondStories)
      delayExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 10) { [weak self] _ in
      let storedStories = try? self?.storage.getStories()
      XCTAssertEqual(storedStories, secondStories + firstStories, "Storage doesn't sort stories")
    }
  }
  
  func testStorageSortsStoriesByDateAndSeenDesc() throws {
    let stories = fakeStories()
    let firstStories = Array(stories[0...2])
    let secondStories = Array(stories[3...5])
    storage.configurator.orderBy([.date, .seen]).orderDirection(.reverse)
    try storage.clear()
    try storage.add(firstStories)
    
    let delayExpectation = expectation(description: "Stories add delay")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      try? self?.storage.add(secondStories)
      delayExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 10) { [weak self] _ in
      let storedStories = try? self?.storage.getStories()
      let sortedStories = secondStories.sorted { $0.isSeen.intValue > $1.isSeen.intValue }
        + firstStories.sorted { $0.isSeen.intValue > $1.isSeen.intValue }

      XCTAssertEqual(storedStories, sortedStories, "Storage doesn't sort stories")
    }
  }
  
  func testStorageSortsStoriesByDateAndSeenDescAsc() throws {
    let stories = fakeStories()
    let firstStories = Array(stories[0...2])
    let secondStories = Array(stories[3...5])
    storage.configurator.orderBy([.date, .seen]).orderDirection([.reverse, .forward])
    try storage.clear()
    try storage.add(firstStories)
    
    let delayExpectation = expectation(description: "Stories add delay")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      try? self?.storage.add(secondStories)
      delayExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 10) { [weak self] _ in
      let storedStories = try? self?.storage.getStories()
      let sortedStories = secondStories.sorted { $0.isSeen.intValue < $1.isSeen.intValue }
        + firstStories.sorted { $0.isSeen.intValue < $1.isSeen.intValue }

      XCTAssertEqual(storedStories, sortedStories, "Storage doesn't sort stories")
    }
  }
  
  func testStorageSortsStoriesBySeenWithoutGivenDirection() throws {
    let stories = fakeStories()
    storage.configurator.orderBy(.seen).orderDirection([])
    try storage.clear()
    try storage.add(stories)
    
    let storedStories = try storage.getStories()
    let sortedStories = stories.sorted { $0.isSeen.intValue < $1.isSeen.intValue }

    XCTAssertEqual(storedStories, sortedStories, "Storage doesn't sort stories")
  }
  
  func testStorageSortsStoriesWithoutGivenParams() throws {
    let stories = fakeStories()
    storage.configurator.orderBy([]).orderDirection([])
    try storage.clear()
    try storage.add(stories)
    
    let storedStories = try storage.getStories()
    
    XCTAssertEqual(storedStories, stories, "Storage doesn't sort stories")
  }

  func testStorageReturnsSeenStories() throws {
    let stories = fakeStories()
    try storage.clear()
    try storage.add(stories)
    
    let seenStories = try storage.getSeenStories()
    
    XCTAssertEqual(seenStories, stories.filter({ $0.isSeen }), "Storage doesn't return seen stories")
  }
  
  func testStorageReturnsNotSeenStories() throws {
    let stories = fakeStories()
    try storage.clear()
    try storage.add(stories)
    
    let seenStories = try storage.getNotSeenStories()
    
    XCTAssertEqual(seenStories, stories.filter({ !$0.isSeen }), "Storage doesn't return not seen stories")
  }
  
  func testStorageSetsStoryAsSeen() throws {
    let story = fakeStories().first { !$0.isSeen }!
    try storage.clear()
    try storage.add(story)
    
    try storage.setStorySeenState(story: story, isSeen: true)
    let storedStory = try storage.getStories { $0.story == story }.first
    
    XCTAssertEqual(storedStory?.isSeen, true, "Storage doesn't mark story as seen")
  }
  
  func testStorageSetsStoryAsNotSeen() throws {
    let story = fakeStories().first { $0.isSeen }!
    try storage.clear()
    try storage.add(story)
    
    try storage.setStorySeenState(story: story, isSeen: false)
    let storedStory = try storage.getStories { $0.story == story }.first
    
    XCTAssertEqual(storedStory?.isSeen, false, "Storage doesn't mark story as not seen")
  }
  
  func testStorageReturnsValidStories() throws {
    let firstStories = Array(fakeStories()[0...1])
    let secondStories = Array(fakeStories()[2...3])
    try storage.clear()
    try storage.add(firstStories, lifetime: 1)
    try storage.add(secondStories, lifetime: 10)
    
    let lifetimeExpectation = expectation(description: "Wait for stories lifetime expiring")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      let stories = try? self?.storage.getValidStories()
      XCTAssertEqual(stories, secondStories, "Storage doesn't return valid stories")
      lifetimeExpectation.fulfill()
    }
    
    wait(for: [lifetimeExpectation], timeout: 5)
  }
  
  func testStorageReturnsValidStoriesWithCustomLifetime() throws {
    let firstStories = Array(fakeStories()[0...1])
    let secondStories = Array(fakeStories()[2...3])
    try storage.clear()
    try storage.add(firstStories, lifetime: 1)
    try storage.add(secondStories, lifetime: 10)
    
    let lifetimeExpectation = expectation(description: "Wait for stories lifetime expiring")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      let stories = try? self?.storage.getValidStories(lifetime: 5)
      XCTAssertEqual(stories, firstStories + secondStories, "Storage doesn't return valid stories")
      lifetimeExpectation.fulfill()
    }
    
    wait(for: [lifetimeExpectation], timeout: 5)
  }
  
  func testStorageReturnsStoriesByGivenCondition() throws {
    let stories = fakeStories()
    try storage.clear()
    try storage.add(stories)
    
    let storedStories = try storage.getStories { $0.story.frames.count == 2 }
    
    XCTAssertEqual(storedStories, stories.filter({ $0.frames.count == 2 }), "Storage doesn't return stories by given condition")
  }
  
  func testStoragesPrefetchesImages() throws {
    storage.configurator.prefetchImages(true)
    let story = fakeStories()[0]
    
    try storage.clear()
    try storage.add(story)
    
    let cacheExpectation = expectation(description: "Wait for image caching")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
      var isCached = ImageCache.default.isCached(forKey: story.imageURL?.absoluteString ?? "")
      story.frames.forEach { frame in
        if !ImageCache.default.isCached(forKey: frame.imageURL?.absoluteString ?? "") {
          isCached = false
        }
      }
      XCTAssertTrue(isCached, "Storage doesn't cache images")
      cacheExpectation.fulfill()
    }
    
    wait(for: [cacheExpectation], timeout: 10)
  }
  
  func testImageCacheRemovingOnDelete() throws {
    storage.configurator.prefetchImages(true)
    let story = fakeStories()[0]
    
    try storage.clear()
    try storage.add(story)
    
    let cacheExpectation = expectation(description: "Wait for image caching")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      try? self?.storage.delete(story)
      
      var isCached = ImageCache.default.isCached(forKey: story.imageURL?.absoluteString ?? "")
      story.frames.forEach { frame in
        if ImageCache.default.isCached(forKey: frame.imageURL?.absoluteString ?? "") {
          isCached = true
        }
      }
      XCTAssertFalse(isCached, "Storage doesn't delete image cache")
      cacheExpectation.fulfill()
    }
    
    wait(for: [cacheExpectation], timeout: 10)
  }
  
  func testImageCacheRemovingOnClear() throws {
    storage.configurator.prefetchImages(true)
    let story = fakeStories()[0]
    
    try storage.clear()
    try storage.add(story)
    
    let cacheExpectation = expectation(description: "Wait for image caching")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
      try? self?.storage.clear()
      
      var isCached = ImageCache.default.isCached(forKey: story.imageURL?.absoluteString ?? "")
      story.frames.forEach { frame in
        if ImageCache.default.isCached(forKey: frame.imageURL?.absoluteString ?? "") {
          isCached = true
        }
      }
      XCTAssertFalse(isCached, "Storage doesn't delete image cache")
      cacheExpectation.fulfill()
    }
    
    wait(for: [cacheExpectation], timeout: 10)
  }
  
  func testStorageSubscribesForUpdatesAndNotifies() throws {
    let mockSubscriber = MockSubscriber()
    
    storage.subscribe(mockSubscriber)
    storage.notify()
    
    XCTAssertTrue(mockSubscriber.hasCalledUpdate, "Storage doesn't call update on subscriber")
  }
  
  func testStorageUnsubscribesFromUpdates() throws {
    let mockSubscriber = MockSubscriber()
    
    storage.subscribe(mockSubscriber)
    storage.notify()
    storage.unsubscribe(mockSubscriber)
    storage.notify()
    
    XCTAssertEqual(mockSubscriber.updateCallsCount, 1, "Storage doesn't unsubscribe a subscriber")
  }
}
