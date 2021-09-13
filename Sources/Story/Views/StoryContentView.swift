//
//  StoryContentView.swift
//  Stories
//

import UIKit

private extension Constants {
  static let softHyphen: String = "&#173;"
  static let unicodeSoftHyphen: String = "\u{00AD}"
}

class StoryContentView: UIStackView {
  // MARK: - Properties
  
  var onDidTapActionButton: (() -> Void)?
  
  private let header1Label = UILabel()
  private let header2Label = UILabel()
  
  private var actionButton: UIButton?
  private var shouldAddHeader1 = false
  private var shouldAddHeader2 = false
  
  private var viewModel: StoryContentViewModelProtocol?
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure
  
  func configure(with viewModel: StoryContentViewModelProtocol) {
    self.viewModel = viewModel
    
    if let alignment = viewModel.contentAlignment {
      self.alignment = alignment
    }
    if let spacing = viewModel.spacing {
      self.spacing = spacing
    }
    
    shouldAddHeader1 = !(viewModel.header1Properties?.text.isEmptyOrNil ?? true)
    shouldAddHeader2 = !(viewModel.header2Properties?.text.isEmptyOrNil ?? true)
    
    setupViews()
  
    configureHeaderLabel(label: header1Label, with: viewModel.header1Properties)
    configureHeaderLabel(label: header2Label, with: viewModel.header2Properties)
    
    for paragraphProperty in viewModel.paragraphsProperties {
      let paragraphLabel = createParagraph(with: paragraphProperty)
      addArrangedSubview(paragraphLabel)
      setCustomSpacing(paragraphProperty.spacingAfterLabel ?? 0, after: paragraphLabel)
    }
    
    actionButton = viewModel.componentsFactory.makeStoryActionButton()
    setupActionButton()
    actionButton?.isHidden = viewModel.actionButtonTitle.isEmptyOrNil
    actionButton?.setTitle(viewModel.actionButtonTitle, for: .normal)
    
    configureLabelsConstraints()
  }
  
  // MARK: - Setup
  
  private func setup() {
    axis = .vertical
  }
  
  private func setupViews() {
    for view in arrangedSubviews {
      removeArrangedSubview(view)
      view.removeFromSuperview()
    }
    
    if shouldAddHeader1 {
      addArrangedSubview(header1Label)
      if let bottomSpacing = viewModel?.header1Properties?.spacingAfterLabel {
        setCustomSpacing(bottomSpacing, after: header1Label)
      }
    }
    
    if shouldAddHeader2 {
      addArrangedSubview(header2Label)
      if let bottomSpacing = viewModel?.header2Properties?.spacingAfterLabel {
        setCustomSpacing(bottomSpacing, after: header2Label)
      }
    }
  }
  
  private func setupActionButton() {
    guard let actionButton = actionButton else { return }
    addArrangedSubview(actionButton)
    actionButton.addTarget(self, action: #selector(onActionButtonTap(_:)), for: .touchUpInside)
  }
  
  // MARK: - Actions
  
  @objc private func onActionButtonTap(_ sender: UIButton) {
    onDidTapActionButton?()
  }
}

// MARK: - Private Methods

private extension StoryContentView {
  func createParagraph(with properties: LabelPropertiesContainer) -> UILabel {
    let paragraphLabel = UILabel()
    let paragraphProperties = makeLabelPropertiesWithHandledSoftHyphen(from: properties)
    paragraphLabel.configure(with: paragraphProperties)
    
    return paragraphLabel
  }
  func makeLabelPropertiesWithHandledSoftHyphen(from properties: LabelPropertiesContainer) -> LabelPropertiesContainer {
    var handledProperties = properties
    handledProperties.text = properties.text?.replacingOccurrences(of: Constants.softHyphen,
                                                                   with: Constants.unicodeSoftHyphen)
    return handledProperties
  }
  func configureHeaderLabel(label: UILabel, with properties: LabelPropertiesContainer?) {
    guard let properties = properties else { return }
    if properties.text.isEmptyOrNil {
      label.isHidden = true
    } else {
      let headerProperties = makeLabelPropertiesWithHandledSoftHyphen(from: properties)
      label.configure(with: headerProperties)
      label.isHidden = false
    }
  }
  func configureLabelsConstraints() {
    switch alignment {
    case .trailing:
      if shouldAddHeader1 {
        header1Label.snp.remakeConstraints { make in
          make.leading.equalToSuperview()
        }
      }
      if shouldAddHeader2 {
        header2Label.snp.remakeConstraints { make in
          make.leading.equalToSuperview()
        }
      }
    case .leading:
      if shouldAddHeader1 {
        header1Label.snp.remakeConstraints { make in
          make.trailing.equalToSuperview()
        }
      }
      if shouldAddHeader2 {
        header2Label.snp.remakeConstraints { make in
          make.trailing.equalToSuperview()
        }
      }
    default:
      break
    }
  }
}
