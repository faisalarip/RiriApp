//
//  StoryMapper.swift
//  Core
//
//  Created by Tech Dev on 5/4/23.
//

import Foundation
import RxSwift

public final class StoryMapper {
  public static func transformStoryRespToModel(response: [StoryResponse]) -> [StoryModel] {
    var data: [StoryModel] = []
    response.forEach {
      data.append(StoryModel(id: $0.id, storyName: $0.storyName, storyContent: $0.storyContent))
    }
    return data
  }
  
  public static func transformStoryModelToResp(data: [StoryModel]) -> [StoryResponse] {
    var dataModel: [StoryResponse] = []
    data.forEach {
      dataModel.append(StoryResponse(id: $0.id, storyName: $0.storyName, storyContent: $0.storyContent))
    }
    return dataModel
  }
}
