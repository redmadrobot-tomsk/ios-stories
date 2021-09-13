//
//  AppDelegate.swift
//  BaseCode
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  // MARK: - Properties
  private var rootNavigationController: NavigationController = NavigationController()
  var window: UIWindow?
  
  // MARK: - App Life Cycle

  func application(_ application: UIApplication, didFinishLaunchingWithOptions
    launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    guard NSClassFromString("XCTestCase") == nil else {
      return true // do not start main coordinator if app is loaded as a unit tests container
    }
    let windowFrame = UIScreen.main.bounds
    let newWindow = UIWindow(frame: windowFrame)
    self.window = newWindow
    window?.rootViewController = rootNavigationController
    window?.makeKeyAndVisible()
    window?.overrideUserInterfaceStyle = .light
    rootNavigationController.pushViewController(ViewController(), animated: false)
    rootNavigationController.setNavigationBarHidden(true, animated: false)
    return true
  }
}
