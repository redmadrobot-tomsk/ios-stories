//
//  Story.swift
//  Stories
//

import UIKit

public struct Story: Codable {
  public var id: String
  public var title: String
  public var imageURL: URL?
  public var frames: [StoryFrame]
  public var isLiked: Bool
  public var isSeen: Bool
  
  public var hasNotShownFrames: Bool {
    return frames.contains { !$0.isAlreadyShown }
  }
  
  enum CodingKeys: String, CodingKey {
    case id, title, imageURL = "image", frames, isLiked, isSeen
  }
  
  public init(id: String = UUID().uuidString, title: String, imageURL: URL?,
              frames: [StoryFrame], isLiked: Bool, isSeen: Bool) {
    self.id = id
    self.title = title
    self.imageURL = imageURL
    self.frames = frames
    self.isLiked = isLiked
    self.isSeen = isSeen
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)
    imageURL = URL(string: (try container.decodeIfPresent(String.self, forKey: .imageURL)) ?? "")
    frames = try container.decode([StoryFrame].self, forKey: .frames)
    isLiked = (try container.decodeIfPresent(Bool.self, forKey: .isLiked)) ?? false
    isSeen = (try container.decodeIfPresent(Bool.self, forKey: .isSeen)) ?? false
  }
}

// MARK: - Equatable

extension Story: Equatable {
  public static func == (lhs: Story, rhs: Story) -> Bool {
    return lhs.id == rhs.id
  }
}
