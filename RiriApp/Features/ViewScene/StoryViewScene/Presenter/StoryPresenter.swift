//
//  StoryPresenter.swift
//  RiriApp
//
//  Created by Tech Dev on 5/3/23.
//
import Foundation
import Core

public final class StoryPresenter {
  
  private var storyInteractor: StoryInteractor
  
  public var stories: [StoryContent] = []
  
  init(storyInteractor: StoryInteractor) {
    self.storyInteractor = storyInteractor
  }
  
  func reqStories(
    isLoad: @escaping(Bool) -> Void,
    completion: @escaping(ResponseResult<Void, String>) -> Void) {
      isLoad(true)
      storyInteractor.retriveStories { result in
        isLoad(false)
        switch result {
        case .Success(let response):
          self.stories = response
          completion(.Success(()))
        case .Error(let error):
          completion(.Error(error))
        }
      }
  }
  
  func saveStories(
    isLoad: @escaping(Bool) -> Void,
    completion: @escaping(ResponseResult<Bool, String>) -> Void) {
      isLoad(true)
      storyInteractor.setStories(stories) { result in
        isLoad(false)
        switch result {
        case .Success(let response):
          completion(.Success(response))
        case .Error(let error):
          completion(.Error(error))
        }
      }
  }
  
}

extension StoryPresenter {
  public func addInitalChildStoryData(_ isChildStory: Bool,_ rowSelected: Int) {
    var childStoryContent: [ChildStoryContent] = []
    
    if isChildStory {
      childStoryContent = stories[rowSelected].childStoryContents
      childStoryContent.append(ChildStoryContent(id: UUID().uuidString, contents: Data()))
      stories[rowSelected].childStoryContents = childStoryContent
    } else {
      stories.append(StoryContent(id: UUID().uuidString,
                                                 storyName: "Story \(stories.count+1)", childStoryContents: [ChildStoryContent(id: UUID().uuidString, contents: Data())]))
    }
    
  }
  
  public func saveChildStoryData(_ rowSelected: Int,
                                 _ rowChildSelected: Int,
                                 _ contentData: Data) {
    stories[rowSelected].childStoryContents[rowChildSelected].contents = contentData
  }
}
