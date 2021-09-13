//
//  UIButton+Default.swift
//  Stories
//

import UIKit

extension UIButton {
  static func makeDefaultButton() -> UIButton {
    let button = UIButton(type: .system)
    button.backgroundColor = .white
    button.setTitleColor(.black, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    button.layer.cornerRadius = 8
    button.snp.makeConstraints { make in
      make.height.equalTo(44)
    }
    return button
  }
}
