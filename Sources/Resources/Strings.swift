//
//  Strings.swift
//  Stories
//

import Foundation

class Strings {
  static let reload = string(for: "reload")
  static let error = string(for: "error")
  static let internetErrorDescription = string(for: "internet.error.description")
  static let serverErrorDescription = string(for: "server.error.description")
  
  private static func string(for key: String) -> String? {
    return NSLocalizedString(key, bundle: Bundle(for: self), comment: "")
  }
}
