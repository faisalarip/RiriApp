//
//  StoryResponse.swift
//  Core
//
//  Created by Tech Dev on 5/3/23.
//

import Foundation

public struct StoryResponse: Codable {
  public let id: String
  public let storyName: String
  public let storyContent: Data
}
