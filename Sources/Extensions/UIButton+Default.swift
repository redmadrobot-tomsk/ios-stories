//
//  UIButton+Default.swift
//  Stories
//

import UIKit

extension UIButton {
  static func makeDefaultButton() -> UIButton {
    let button = UIButton(type: .system)
    var configuration = UIButton.Configuration.plain()
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    configuration.background.backgroundColor = .white
    configuration.background.cornerRadius = 8
    configuration.cornerStyle = .fixed
    configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
      var outgoing = incoming
      outgoing.foregroundColor = .black
      outgoing.font = .boldSystemFont(ofSize: 16)
      return outgoing
    }
    button.configuration = configuration
    button.snp.makeConstraints { make in
      make.height.equalTo(44)
    }
    return button
  }
}
