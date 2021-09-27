//
//  Optional+IsEmptyOrNil.swift
//  Stories
//

import Foundation

extension Optional where Wrapped: Collection {
  var isEmptyOrNil: Bool {
    return self?.isEmpty ?? true
  }
}
