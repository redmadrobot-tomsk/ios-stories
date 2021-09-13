//
//  StoriesListCell.swift
//  Stories
//

import UIKit

open class StoriesListCell: UICollectionViewCell, ReuseIdentifiable {
  // MARK: - Properties
  
  /// Base container, nested into `contentView` and containing other views
  public let containerView = UIView()
  /// Story  preview image
  public let imageView = UIImageView()
  /// Story title
  public let titleLabel = UILabel()
  
  /// Frame of the image view
  public var imageFrame: CGRect {
    convert(imageView.frame, from: containerView)
  }
  
  /// Size of the story preview cell.
  /// Override this property in custom cells to set correct size.
  open class var cellSize: CGSize {
    return Constants.defaultStoriesListCellSize
  }
  
  // MARK: - Init
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public methods
  
  /// Configures view with story. Override this method to add additional configuration.
  /// - Parameter story: The story that will be shown after tap on current view.
  open func configure(with story: Story) {
    imageView.setImage(with: story.imageURL)
    titleLabel.text = story.title
  }
  
  /// Setups cell views. Override this method to setup custom layout
  open func setup() {
    setupContentView()
    setupContainerView()
    setupImageView()
    setupTitleLabel()
    setupAdditionalProperties()
  }
  
  /// Add additional properties to subviews or override existing after setup.
  /// You can additionally setup `contentView`, `containerView`, `imageView` or `titleLabel`.
  open func setupAdditionalProperties() {
    // Do nothing
  }
  
  // MARK: - Private methods
  
  private func setupContentView() {
    contentView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
    contentView.layer.shadowOffset = CGSize(width: 0, height: 6)
    contentView.layer.shadowRadius = 16
    contentView.layer.shadowOpacity = 1
    contentView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: .zero,
                                                                    size: Constants.defaultStoriesListCellSize),
                                                cornerRadius: 8).cgPath
  }
  
  private func setupContainerView() {
    contentView.addSubview(containerView)
  
    containerView.backgroundColor = .white
    containerView.layer.cornerRadius = 8

    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
  }
  
  private func setupImageView() {
    containerView.addSubview(imageView)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.layer.cornerRadius = 8
    imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    imageView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.height.equalTo(80)
    }
  }
  
  private func setupTitleLabel() {
    containerView.addSubview(titleLabel)
    titleLabel.font = .boldSystemFont(ofSize: 12)
    titleLabel.numberOfLines = 3
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(imageView.snp.bottom).offset(10)
      make.leading.trailing.equalToSuperview().inset(12)
      make.bottom.lessThanOrEqualToSuperview().inset(12)
    }
  }
}
