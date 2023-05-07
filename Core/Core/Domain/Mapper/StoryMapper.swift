//
//  StoryMapper.swift
//  Core
//
//  Created by Tech Dev on 5/4/23.
//

import Foundation
import RxSwift

public final class StoryMapper {
  public static func transformStoryRespToModel(response: [StoryContentResponse]) -> [StoryContent] {
    var storyData: [StoryContent] = []
    var childData: [ChildStoryContent] = []
    
    response.forEach {
      childData = $0.childStoryContents.map { ChildStoryContent(id: $0.id, contents: $0.contents) }
      storyData.append(StoryContent(id: $0.id, storyName: $0.storyName, childStoryContents: childData))
    }
    return storyData
  }
  
  public static func transformStoryModelToResp(data: [StoryContent]) -> [StoryContentResponse] {
    var storyData: [StoryContentResponse] = []
    var childData: [ChildStoryContentResponse] = []
    
    data.forEach {
      childData = $0.childStoryContents.map { ChildStoryContentResponse(id: $0.id, contents: $0.contents) }
      storyData.append(StoryContentResponse(id: $0.id, storyName: $0.storyName, childStoryContents: childData))
    }
    return storyData
  }
}
