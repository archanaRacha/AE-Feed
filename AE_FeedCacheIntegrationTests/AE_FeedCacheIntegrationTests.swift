//
//  AE_FeedCacheIntegrationTests.swift
//  AE_FeedCacheIntegrationTests
//
//  Created by archana racha on 04/06/24.
//

import XCTest
import AE_Feed

final class AE_FeedCacheIntegrationTests: XCTestCase {

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for load completion")
        sut.load{ result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed,[], "Expected empty feed")
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1.0)
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    // MARK: Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
            let storeBundle = Bundle(for: CoreDataFeedStore.self)
            let storeURL = testSpecificStoreURL()
            let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
            let sut = LocalFeedLoader(store: store, currentDate: Date.init)
            trackMemoryLeaks(store, file: file, line: line)
            trackMemoryLeaks(sut, file: file, line: line)
            return sut
        }

        private func testSpecificStoreURL() -> URL {
            return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
        }

        private func cachesDirectory() -> URL {
            return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        }

}
