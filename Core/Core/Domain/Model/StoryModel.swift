//
//  StoryModel.swift
//  Core
//
//  Created by Tech Dev on 5/3/23.
//

import Foundation

public struct StoryModel {
  public init(id: String = "0",
              storyName: String = "",
              storyContent: Data = Data()) {
    self.id = id
    self.storyName = storyName
    self.storyContent = storyContent
  }
  
  public var id: String
  public var storyName: String
  public var storyContent: Data
}
