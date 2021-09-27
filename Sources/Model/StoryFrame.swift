//
//  StoryFrame.swift
//  Stories
//

import UIKit

public enum FrameControlsColorMode: String, Codable {
  case light
  case dark
}

public struct FrameAction: Codable {
  public let text: String
  public let urlString: String
  
  enum CodingKeys: String, CodingKey {
    case text = "name", urlString = "url"
  }
  
  public init(text: String, urlString: String) {
    self.text = text
    self.urlString = urlString
  }
}

public struct StoryFrameContent: Codable {
  public let position: FrameContentPosition
  public let textColor: UIColor
  public let gradientColor: UIColor?
  public let gradientStartAlpha: CGFloat?
  public let header1: String?
  public let header2: String?
  public let paragraphs: [String]
  public let action: FrameAction?
  public let controlsColorMode: FrameControlsColorMode
  public let gradient: StoryFrameGradient
  
  enum CodingKeys: String, CodingKey {
    case position, textColor = "textColor", gradientColor = "gradientColor", gradientStartAlpha, header1,
         header2, paragraphs = "descriptions", action, controlsColorMode = "controlsColor", gradient
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(position, forKey: .position)
    try container.encode(gradientStartAlpha, forKey: .gradientStartAlpha)
    try container.encode(header1, forKey: .header1)
    try container.encode(header2, forKey: .header2)
    try container.encode(paragraphs, forKey: .paragraphs)
    try container.encode(action, forKey: .action)
    try container.encode(controlsColorMode, forKey: .controlsColorMode)
    try container.encode(gradient, forKey: .gradient)
    try container.encode(textColor.toHexString, forKey: .textColor)
    try container.encode(gradientColor?.toHexString, forKey: .gradientColor)
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    position = try container.decode(FrameContentPosition.self, forKey: .position)
    gradientStartAlpha = try container.decodeIfPresent(CGFloat.self, forKey: .gradientStartAlpha)
    header1 = try container.decodeIfPresent(String.self, forKey: .header1)
    header2 = try container.decodeIfPresent(String.self, forKey: .header2)
    paragraphs = try container.decode([String].self, forKey: .paragraphs)
    action = try container.decodeIfPresent(FrameAction.self, forKey: .action)
    controlsColorMode = try container.decode(FrameControlsColorMode.self, forKey: .controlsColorMode)
    gradient = try container.decode(StoryFrameGradient.self, forKey: .gradient)
    textColor = UIColor(hexString: (try container.decode(String.self, forKey: .textColor)))
    
    if let gradientColorHEX = (try container.decodeIfPresent(String.self, forKey: .gradientColor)) {
      gradientColor = UIColor(hexString: gradientColorHEX)
    } else {
      gradientColor = nil
    }
  }
  
  public init(position: FrameContentPosition,
              textColor: UIColor,
              header1: String?,
              header2: String?,
              paragraphs: [String],
              action: FrameAction?,
              controlsColorMode: FrameControlsColorMode,
              gradient: StoryFrameGradient,
              gradientColor: UIColor? = nil,
              gradientStartAlpha: CGFloat = 0.7) {
    self.position = position
    self.textColor = textColor
    self.header1 = header1
    self.header2 = header2
    self.paragraphs = paragraphs
    self.action = action
    self.controlsColorMode = controlsColorMode
    self.gradient = gradient
    self.gradientColor = gradientColor
    self.gradientStartAlpha = gradientStartAlpha
  }
}

public struct StoryFrame: Codable {
  public let content: StoryFrameContent
  public let imageURL: URL?
  
  public var isAlreadyShown: Bool
  
  enum CodingKeys: String, CodingKey {
    case content, imageURL = "image", isAlreadyShown
  }
  
  public init(content: StoryFrameContent, imageURL: URL?, isAlreadyShown: Bool) {
    self.content = content
    self.imageURL = imageURL
    self.isAlreadyShown = isAlreadyShown
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    content = try container.decode(StoryFrameContent.self, forKey: .content)
    imageURL = URL(string: (try container.decodeIfPresent(String.self, forKey: .imageURL)) ?? "")
    isAlreadyShown = (try container.decodeIfPresent(Bool.self, forKey: .isAlreadyShown)) ?? false
  }
}
