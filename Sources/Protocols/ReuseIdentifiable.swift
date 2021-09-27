//
//  ReuseIdentifiable.swift
//  Stories
//

import UIKit

protocol ReuseIdentifiable {
  static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}
