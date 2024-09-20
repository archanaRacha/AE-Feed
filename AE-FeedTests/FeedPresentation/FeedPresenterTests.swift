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
    static func error(message:String) -> FeedErrorViewModel{
        return FeedErrorViewModel(message: message)
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
    var feedLoadError:String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",tableName: "Feed",bundle: Bundle(for: FeedPresenter.self), comment: "Error message displayed when we can't load the image feed from the server.")
    }
    init(feedView: FeedView, loadingView: FeedLoadingView,errorView: FeedErrorView){
        self.feedView = feedView
        self.errorView = errorView
        self.loadingView = loadingView
    }
    static var title : String{
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self)
                                 ,comment: "Title for the feed view")
    }
    func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    func didFinishedLoadingFeed(with feed:[FeedImage]){
      
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    func didFinishedLoadingFeed(with error:Error){
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
class FeedPresenterTests: XCTestCase {

    func test_title_isLocalized(){
        XCTAssertEqual(FeedPresenter.title, localized("FEED_VIEW_TITLE"))
    }
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
    func test_didFinishedLoadingFeedWithError(){
        let (sut,view) = makeSUT()
        sut.didFinishedLoadingFeed(with: anyNSError())
        XCTAssertEqual(view.messages, [.display(errorMessage:localized("FEED_VIEW_CONNECTION_ERROR")),
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
    private func localized(_ key: String, file:StaticString = #file, line : UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for:FeedPresenter.self)
        let value = bundle.localizedString(forKey:key,value :nil,table:"Feed")
        if key == value {
            XCTFail("Missing localized string for key:\(key) in table \(table)", file: file,line:line)
        }
        return value
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
