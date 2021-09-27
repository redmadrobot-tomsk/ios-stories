//
//  MockSubscriber.swift
//  StoriesTests
//

import Foundation
@testable import Stories

class MockSubscriber: Subscriber {
  private(set) var hasCalledUpdate = false
  private(set) var updateCallsCount: Int = 0
  
  func update() {
    hasCalledUpdate = true
    updateCallsCount += 1
  }
}
