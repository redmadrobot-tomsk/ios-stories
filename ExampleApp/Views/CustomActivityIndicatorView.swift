//
//  CustomActivityIndicatorView.swift
//  StoriesExampleApp
//

import UIKit
import Stories

class CustomActivityIndicatorView: UIStackView, ActivityIndicatorViewProtocol {
  var hidesWhenStopped: Bool = false
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func startAnimating() {
    setup()
    isHidden = false
  }
  
  func stopAnimating() {
    arrangedSubviews.forEach { $0.removeFromSuperview() }
    isHidden = hidesWhenStopped
  }
  
  private func setup() {
    arrangedSubviews.forEach { $0.removeFromSuperview() }
    spacing = 4
    
    var delay: TimeInterval = 0
    
    for _ in 1...3 {
      let circleView = UIView()
      circleView.backgroundColor = .gray
      circleView.layer.cornerRadius = 4
      circleView.snp.makeConstraints { make in
        make.size.equalTo(8)
      }
      addArrangedSubview(circleView)
      
      UIView.animate(withDuration: 0.45, delay: delay, options: [.repeat, .autoreverse, .curveEaseInOut],
                     animations: {
        circleView.transform = CGAffineTransform(translationX: 0, y: -16)
      }, completion: nil)
      
      delay += 0.15
    }
  }
}
