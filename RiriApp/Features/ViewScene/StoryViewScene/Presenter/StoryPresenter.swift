//
//  StoryPresenter.swift
//  RiriApp
//
//  Created by Tech Dev on 5/3/23.
//
import Foundation
import RxSwift
import Core

public final class StoryPresenter {
  
  private var storyInteractor: StoryInteractor
  private let disposeBag = DisposeBag()
  
  public var stories: [StoryContent] = []
  
  init(storyInteractor: StoryInteractor) {
    self.storyInteractor = storyInteractor
  }
  
  func reqStories(
    isLoad: @escaping(Bool) -> Void,
    completion: @escaping(ResponseResult<Void, String>) -> Void) {
    
      storyInteractor.retriveStories()
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { response in
          self.stories = response
          isLoad(false)
          completion(.Success(()))
        },
        onError: { error in
          isLoad(false)
          completion(.Error(error.localizedDescription))
        })
      .disposed(by: disposeBag)
  }
  
  func saveStories(
    isLoad: @escaping(Bool) -> Void,
    completion: @escaping(ResponseResult<Bool, String>) -> Void) {
      
      storyInteractor.setStories(stories)
      .observeOn(MainScheduler.instance)
      .subscribe(
        onNext: { response in
          isLoad(false)
          completion(.Success((response)))
        },
        onError: { error in
          isLoad(false)
          completion(.Error(error.localizedDescription))
        })
      .disposed(by: disposeBag)
  }
  
}

extension StoryPresenter {
  public func addInitalChildStoryData(_ rowSelected: Int) {
    var childStoryContent: [ChildStoryContent] = []
    if stories.isEmpty {
      stories.append(StoryContent(id: UUID().uuidString,
                                                 storyName: "Story \(stories.count+1)", childStoryContents: [ChildStoryContent(id: UUID().uuidString, contents: Data())]))
    } else {
      childStoryContent = stories[rowSelected].childStoryContents
      childStoryContent.append(ChildStoryContent(id: UUID().uuidString, contents: Data()))
      stories[rowSelected].childStoryContents = childStoryContent
    }
    
  }
  
  public func saveChildStoryData(_ rowSelected: Int,
                                 _ rowChildSelected: Int,
                                 _ contentData: Data) {
    stories[rowSelected].childStoryContents[rowChildSelected].contents = contentData
  }
}
