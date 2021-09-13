//
//  Publisher.swift
//  Stories
//

import Foundation

protocol Publisher {
  func subscribe(_ subscriber: Subscriber)
  func unsubscribe(_ subscriber: Subscriber)
}
