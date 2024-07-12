//
//  FeedViewControllerTests.swift
//  Prototype
//
//  Created by archana racha on 12/07/24.
//

import XCTest
import UIKit
import AE_Feed

final class FeedViewcontroller : UIViewController {
    private var loader : FeedLoader?
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load{ _ in }
    }
}
final class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_,loader) = makeSUT()
        _ = FeedViewcontroller(loader:loader)
        XCTAssertEqual(loader.loadCallCount, 0 )
    }
    
    func test_viewDidLoad_loadsFeed(){
        let (sut,loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    // MARK: Helpers
    
    private func makeSUT(file: StaticString = #file,line: UInt = #line) -> (sut : FeedViewcontroller,loader:LoaderSpy){
        let loader = LoaderSpy()
        let sut = FeedViewcontroller(loader: loader)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return (sut,loader)
    }
    class LoaderSpy: FeedLoader {
        private(set) var loadCallCount : Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCallCount += 1
        }
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

//    func testExample() throws {
//        // UI tests must launch the application that they test.
//        let app = XCUIApplication()
//        app.launch()
//
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//    }
//
//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
