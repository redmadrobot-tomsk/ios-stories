//
//  CustomErrorStateView.swift
//  StoriesExampleApp
//

import UIKit
import Stories

class CustomErrorStateView: UIView, StoryErrorStateViewProtocol {
  var onDidRequestToReload: (() -> Void)?
  
  private let stackView = UIStackView()
  private let smileLabel = UILabel()
  private let titleLabel = UILabel()
  private let reloadButton = UIButton(type: .system)
  
  init() {
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  @objc private func didTapReload() {
    onDidRequestToReload?()
  }
  
  func configure(with error: Stories.NetworkError) {
    switch error {
    case .offline:
      titleLabel.text = "Нет интернета"
    case .serverError:
      titleLabel.text = "Ошибка сервера"
    }
  }
  
  private func setup() {
    backgroundColor = .black
    setupStackView()
    setupSmileLabel()
    setupTitleLabel()
    setupReloadButton()
  }
  
  private func setupStackView() {
    addSubview(stackView)
    stackView.axis = .vertical
    stackView.snp.makeConstraints { make in
      make.center.equalToSuperview()
    }
  }
  
  private func setupSmileLabel() {
    stackView.addArrangedSubview(smileLabel)
    smileLabel.textColor = .white
    smileLabel.font = .boldSystemFont(ofSize: 56)
    smileLabel.text = ":("
    smileLabel.textAlignment = .center
    stackView.setCustomSpacing(16, after: smileLabel)
  }
  
  private func setupTitleLabel() {
    stackView.addArrangedSubview(titleLabel)
    titleLabel.textColor = .white
    titleLabel.font = .boldSystemFont(ofSize: 16)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 0
    stackView.setCustomSpacing(24, after: titleLabel)
  }
  
  private func setupReloadButton() {
    stackView.addArrangedSubview(reloadButton)
    reloadButton.setTitle("Обновить", for: .normal)
    reloadButton.setTitleColor(.white, for: .normal)
    reloadButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    reloadButton.layer.borderWidth = 1
    reloadButton.layer.borderColor = UIColor.white.cgColor
    reloadButton.layer.cornerRadius = 22
    reloadButton.addTarget(self, action: #selector(didTapReload), for: .touchUpInside)
    reloadButton.snp.makeConstraints { make in
      make.height.equalTo(44)
    }
  }
}
