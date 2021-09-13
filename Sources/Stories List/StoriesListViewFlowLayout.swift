//
//  StoriesListViewFlowLayout.swift
//  Stories
//

import UIKit

class StoriesListViewFlowLayout: UICollectionViewFlowLayout {
  override init() {
    super.init()
    self.scrollDirection = .horizontal
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
