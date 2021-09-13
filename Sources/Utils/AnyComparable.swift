//
//  AnyComparable.swift
//  Stories
//

import Foundation

struct AnyComparable: Comparable {
  let value: Any
  let isLess: (Any) -> Bool
  let isEqual: (Any) -> Bool
  
  init<T: Comparable>(_ value: T) {
    self.value = value
    self.isLess = {
      guard let otherValue = $0 as? T else { return false }
      return value < otherValue
    }
    self.isEqual = { ($0 as? T) == value }
  }
  
  static func < (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
    lhs.isLess(rhs.value)
  }
  
  static func == (lhs: AnyComparable, rhs: AnyComparable) -> Bool {
    lhs.isEqual(rhs.value)
  }
}
