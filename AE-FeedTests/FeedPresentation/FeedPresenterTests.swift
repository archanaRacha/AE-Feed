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
protocol FeedErrorView{
    func display(_ viewModel:FeedErrorViewModel)
}

final class FeedPresenter{
    private let errorView:FeedErrorView
    init(errorView: FeedErrorView){
        self.errorView = errorView
    }
    func didStartLoadingFeed(){
        errorView.display(.noError)
    }
}
class FeedPresenterTests: XCTestCase {

    func test_inti_doesNotSendMessagesToView(){
        let (_,view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty,"Expected no view messages")
    }
    func test_didStartLoadingFeed_dispayNoErrorMessage(){
        let (sut,view) = makeSUT()
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage:.none)])
    }
   // MARK: Helpers
    private func makeSUT(file:StaticString = #file,line:UInt = #line) -> (sut:FeedPresenter,view:ViewSpy){
        let errorView = ViewSpy()
        let sut = FeedPresenter(errorView: errorView)
        trackMemoryLeaks(errorView,file:file,line:line)
        trackMemoryLeaks(sut,file:file,line:line)
        return (sut,errorView)
    }
    private class ViewSpy: FeedErrorView {
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        enum Message : Equatable{
            case display(errorMessage:String?)
        }
        private(set) var messages = [Message]()
    }

}
