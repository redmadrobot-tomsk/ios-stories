//
//  CustomStoryCell.swift
//  Stories
//

import UIKit
import Stories

class CustomStoryCell: StoriesListCell {
  override class var cellSize: CGSize {
    return CGSize(width: 80, height: 120)
  }
  
  override func configure(with story: Story) {
    imageView.setImage(with: story.imageURL)
    titleLabel.text = story.title
    
    if story.isSeen {
      imageView.layer.borderWidth = 0
    } else {
      imageView.layer.borderWidth = 2
      imageView.layer.borderColor = UIColor.orange.cgColor
    }
  }
  
  override func setup() {
    addSubview(containerView)
    containerView.layer.cornerRadius = 40
    containerView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.size.equalTo(80)
    }
    
    containerView.addSubview(imageView)
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 40
    imageView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner,
                                     .layerMinXMaxYCorner, .layerMinXMinYCorner]
    imageView.clipsToBounds = true
    imageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    addSubview(titleLabel)
    titleLabel.font = .boldSystemFont(ofSize: 12)
    titleLabel.numberOfLines = 2
    titleLabel.textAlignment = .center
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(8)
      make.leading.trailing.equalToSuperview()
    }
  }
}
