//
//  StoryResponse.swift
//  Core
//
//  Created by Tech Dev on 5/3/23.
//

import Foundation

public struct StoryContentResponse: Codable {
  public let id: String
  public let storyName: String
  public let childStoryContents: [ChildStoryContentResponse]
}

public struct ChildStoryContentResponse: Codable {
  public let id: String
  public let contents: Data
}

