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
        let view = ViewSpy()
        _ = FeedPresenter(view:view)
        XCTAssertTrue(view.messages.isEmpty,"Expected no view messages")
    }
   // MARK: Helpers
    private class ViewSpy {
        let messages = [Any]()
    }

}
