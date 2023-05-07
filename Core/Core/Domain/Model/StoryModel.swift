//
//  StoryModel.swift
//  Core
//
//  Created by Tech Dev on 5/3/23.
//

import Foundation

public struct StoryContent {
  public init(id: String = "0",
              storyName: String = "",
              childStoryContents: [ChildStoryContent] = []) {
    self.id = id
    self.storyName = storyName
    self.childStoryContents = childStoryContents
  }
  
  public var id: String
  public var storyName: String
  public var childStoryContents: [ChildStoryContent]
}

public struct ChildStoryContent {
  public init(id: String = "0",
              contents: Data = Data()) {
    self.id = id
    self.contents = contents
  }
  
  public var id: String
  public var contents: Data
}
