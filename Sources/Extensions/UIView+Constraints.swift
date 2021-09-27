//
//  UIView+Constraints.swift
//  Stories
//

import UIKit
import SnapKit

extension UIView {
  func setEqualToSuperviewConstraints(from constraints: ViewConstraintsContainer) {
    snp.makeConstraints { make in
      if let top = constraints.topOffset {
        make.top.equalToSuperview().offset(top)
      }
      if let bottom = constraints.bottomOffset {
        make.bottom.equalToSuperview().offset(bottom)
      }
      if let trailing = constraints.trailingOffset {
        make.trailing.equalToSuperview().offset(trailing)
      }
      if let leading = constraints.leadingOffset {
        make.leading.equalToSuperview().offset(leading)
      }
      if let centerXOffset = constraints.centerXOffset {
        make.centerX.equalToSuperview().offset(centerXOffset)
      }
      if let centerYOffset = constraints.centerYOffset {
        make.centerY.equalToSuperview().offset(centerYOffset)
      }
      if let width = constraints.width {
        make.width.equalTo(width)
      }
      if let height = constraints.height {
        make.height.equalTo(height)
      }
    }
  }
}
