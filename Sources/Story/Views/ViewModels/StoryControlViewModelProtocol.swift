//
//  StoryControlViewModelProtocol.swift
//  Stories
//

import UIKit

protocol StoryControlViewModelProtocol {
  var closeIcon: UIImage? { get set }
  var controlsTintColor: UIColor { get set }
  var progressViewConstraints: ViewConstraintsContainer { get set }
  var closeButtonConstraints: ViewConstraintsContainer { get set }
  var likeButtonConstraints: ViewConstraintsContainer? { get set }
}
