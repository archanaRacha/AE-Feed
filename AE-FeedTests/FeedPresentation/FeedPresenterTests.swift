//
//  FeedPresenterTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 16/09/24.
//

import XCTest

final class FeedPresenter{
    init(view: Any){
        
    }
}
class FeedPresenterTests: XCTestCase {

    func test_inti_doesNotSendMessagesToView(){
        let (_,view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty,"Expected no view messages")
    }
   // MARK: Helpers
    private func makeSUT(file:StaticString = #file,line:UInt = #line) -> (sut:FeedPresenter,view:ViewSpy){
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        trackMemoryLeaks(view,file:file,line:line)
        return (sut,view)
    }
    private class ViewSpy {
        let messages = [Any]()
    }

}
