//
//  StoryControlViewModel.swift
//  Stories
//

import UIKit

class StoryControlViewModel: StoryControlViewModelProtocol {
  var closeIcon: UIImage? = nil
  var controlsTintColor: UIColor
  var progressViewConstraints: ViewConstraintsContainer
  var closeButtonConstraints: ViewConstraintsContainer
  var likeButtonConstraints: ViewConstraintsContainer?
  
  init(colorMode: FrameControlsColorMode) {
    switch colorMode {
    case .light:
      controlsTintColor = .white
    case .dark:
      controlsTintColor = .black
    }
    progressViewConstraints = ViewConstraintsContainer(topOffset: 0, leadingOffset: 16, trailingOffset: -16, height: 3)
    closeButtonConstraints = ViewConstraintsContainer(topOffset: 18, bottomOffset: 0, trailingOffset: -16, width: 40, height: 40)
    likeButtonConstraints = ViewConstraintsContainer(topOffset: 18, leadingOffset: 16, width: 40, height: 40)
    closeIcon = ImageProvider.close()
  }
}
