//
//  TransitionAnimator.swift
//  Stories
//

import UIKit

class TransitionAnimator: NSObject, UIViewControllerTransitioningDelegate {
  var storiesPresentAnimationController: UIViewControllerAnimatedTransitioning?
  var storiesDismissAnimationController: UIViewControllerAnimatedTransitioning?
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                           source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return storiesPresentAnimationController
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return storiesDismissAnimationController
  }
  
  func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                              source: UIViewController) -> UIPresentationController? {
    return StoryPresentationController(presentedViewController: presented, presenting: presenting)
  }
}
