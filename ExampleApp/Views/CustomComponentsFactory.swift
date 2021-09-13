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
    button.backgroundColor = .orange
    button.layer.cornerRadius = 22
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    button.setTitleColor(.white, for: .normal)
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
