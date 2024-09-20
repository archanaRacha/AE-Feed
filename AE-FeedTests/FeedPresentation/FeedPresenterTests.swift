//
//  FeedPresenterTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 16/09/24.
//

import XCTest

struct FeedErrorViewModel{
    let message: String?
    static var noError:FeedErrorViewModel{
        return FeedErrorViewModel(message: nil)
    }
}
struct FeedLoadingViewModel{
    let isLoading:Bool
}
protocol FeedErrorView{
    func display(_ viewModel:FeedErrorViewModel)
}
protocol FeedLoadingView {
    func display(_ viewModel:FeedLoadingViewModel)
}
final class FeedPresenter{
    private let errorView:FeedErrorView
    private let loadingView:FeedLoadingView
    init(loadingView: FeedLoadingView,errorView: FeedErrorView){
        self.errorView = errorView
        self.loadingView = loadingView
    }
    func didStartLoadingFeed(){
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
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
   // MARK: Helpers
    private func makeSUT(file:StaticString = #file,line:UInt = #line) -> (sut:FeedPresenter,view:ViewSpy){
        let view = ViewSpy()
        let sut = FeedPresenter(loadingView:view ,errorView: view)
        trackMemoryLeaks(view,file:file,line:line)
        trackMemoryLeaks(sut,file:file,line:line)
        return (sut,view)
    }
    private class ViewSpy: FeedErrorView, FeedLoadingView {
    
        enum Message : Hashable{
            case display(errorMessage:String?)
            case display(isLoading:Bool)
        }
        private(set) var messages = Set<Message>()
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.insert(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.insert(.display(errorMessage: viewModel.message))
        }
    }

}
