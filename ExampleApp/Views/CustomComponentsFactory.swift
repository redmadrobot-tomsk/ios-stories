//
//  CustomComponentsFactory.swift
//  StoriesExampleApp
//

import UIKit
import Stories

class CustomComponentsFactory: StoriesUIComponentsFactory {
  override func storiesListCellType() -> StoriesListCell.Type {
    return CustomStoryCell.self
  }
  
  override func makeStoryActionButton() -> UIButton {
    let button = UIButton(type: .system)
    var configuration = UIButton.Configuration.plain()
    configuration.background.backgroundColor = .orange
    configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
    configuration.cornerStyle = .capsule
    configuration.baseForegroundColor = .white
    button.configuration = configuration
    button.snp.makeConstraints { make in
      make.height.equalTo(44)
    }
    return button
  }
  
  override func makeErrorStateView() -> StoryErrorStateViewProtocol {
    return CustomErrorStateView()
  }
  
  override func makeActivityIndicatorView() -> ActivityIndicatorViewProtocol {
    return CustomActivityIndicatorView()
  }
}
