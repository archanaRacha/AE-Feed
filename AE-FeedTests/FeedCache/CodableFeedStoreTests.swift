//
//  CodableFeedStoreTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 22/05/24.
//

import XCTest
import AE_Feed

class CodableFeedStore {
    func retrieve(completion:@escaping FeedStore.RetrievalCompletions) {
        completion(.empty)
    }
}
final class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default: XCTFail("Expeccted empty result, got \(result) instead")
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
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
