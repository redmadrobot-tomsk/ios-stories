//
//  NavigationController.swift
//  BaseCode
//

import UIKit

class NavigationController: UINavigationController {
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return topViewController?.preferredStatusBarStyle ?? .lightContent
  }
  
  override var prefersStatusBarHidden: Bool {
    return topViewController?.prefersStatusBarHidden ?? false
  }
  
  override var shouldAutorotate: Bool {
    return topViewController?.shouldAutorotate ?? true
  }
  
  override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return topViewController?.supportedInterfaceOrientations ?? .portrait
  }
  
  override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
    return topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
  }
  
  override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
    return topViewController?.preferredStatusBarUpdateAnimation ?? .slide
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
  }
  
  // MARK: - Navigation Bar Appearance
  
  func configureNavigationBarAppearance() {
    navigationBar.barTintColor = .clear
    navigationBar.tintColor = .black
    navigationBar.shadowImage = UIImage()
    navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationBar.isTranslucent = true
    navigationBar.backgroundColor = .clear
    view.backgroundColor = .white
  }
}
