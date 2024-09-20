//
//  FeedPresenterTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 16/09/24.
//

import XCTest
import AE_Feed

struct FeedErrorViewModel{
    let message: String?
    static var noError:FeedErrorViewModel{
        return FeedErrorViewModel(message: nil)
    }
}
struct FeedLoadingViewModel{
    let isLoading:Bool
}
struct FeedViewModel{
    let feed:[FeedImage]
}
protocol FeedErrorView{
    func display(_ viewModel:FeedErrorViewModel)
}
protocol FeedLoadingView {
    func display(_ viewModel:FeedLoadingViewModel)
}
protocol FeedView{
    func display(_ viewModel:FeedViewModel)
}

final class FeedPresenter{
    private let feedView:FeedView
    private let loadingView:FeedLoadingView
    private let errorView:FeedErrorView
    
    init(feedView: FeedView, loadingView: FeedLoadingView,errorView: FeedErrorView){
        self.feedView = feedView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    func didFinishedLoadingFeed(with feed:[FeedImage]){
      
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
class FeedPresenterTests: XCTestCase {

    func test_inti_doesNotSendMessagesToView(){
        let (_,view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty,"Expected no view messages")
    }
    func test_didStartLoadingFeed_dispayNoErrorMessageAndStartsLoading(){
        let (sut,view) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage:.none),
             .display(isLoading:true)])
    }
    func test_didFinishedLoadingFeed_displayFeedAndStopsLoading(){
        let (sut,view) = makeSUT()
        let feed = uniqueImageFeed().models
        sut.didFinishedLoadingFeed(with: feed)
        XCTAssertEqual(view.messages, [.display(feed:feed),
            .display(isLoading: false)])
        
    }
   // MARK: Helpers
    private func makeSUT(file:StaticString = #file,line:UInt = #line) -> (sut:FeedPresenter,view:ViewSpy){
        let view = ViewSpy()
        let sut = FeedPresenter(feedView: view, loadingView:view ,errorView: view)
        trackMemoryLeaks(view,file:file,line:line)
        trackMemoryLeaks(sut,file:file,line:line)
        return (sut,view)
    }
    private class ViewSpy: FeedErrorView, FeedLoadingView,FeedView {
        
        enum Message : Hashable{
            
            case display(errorMessage:String?)
            case display(isLoading:Bool)
            case display(feed:[FeedImage])
        }
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
        func display(_ viewModel: FeedViewModel) {
            messages.insert(.display(feed: viewModel.feed))
        }
        
    }

}
