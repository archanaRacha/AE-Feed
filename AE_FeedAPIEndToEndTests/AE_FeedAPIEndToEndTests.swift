//
//  AE_FeedAPIEndToEndTests.swift
//  AE_FeedAPIEndToEndTests
//
//  Created by archana racha on 10/03/24.
//

import XCTest
import AE_Feed

final class AE_FeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerFetFeedResult_matchesFixedTestAccountData() {
        let client = URLSessionHTTPClient()
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let loader = RemoteFeedLoader(client: client, url: testServerURL)
        let exp = expectation(description: "wait for load completion")
        var receivedResult : LoadFeedResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        switch receivedResult {
        case .success(let array):
            XCTAssertEqual(array.count, 8, "Expected 8 items in the test account feed")
            XCTAssertEqual(array[0], expectedFeedItems(at :0))
            XCTAssertEqual(array[1], expectedFeedItems(at :1))
            XCTAssertEqual(array[2], expectedFeedItems(at :2))
            XCTAssertEqual(array[3], expectedFeedItems(at :3))
            XCTAssertEqual(array[4], expectedFeedItems(at :4))
            XCTAssertEqual(array[5], expectedFeedItems(at :5))
            XCTAssertEqual(array[6], expectedFeedItems(at :6))
            XCTAssertEqual(array[7], expectedFeedItems(at :7))
        case .failure(let error):
                XCTFail("Expected successful feed result, got \(error) instead")
      
        case .none:
            XCTFail("Expected successfull feed result, got no result instead")
        }
    }
    //MARK: Helper functions
    private func expectedFeedItems(at index:Int) -> FeedItem {
        return FeedItem(id: id(at : index) , description: description(at : index), location: location(at : index), imageURL: imageURL(at : index))
    }
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
        ][index])!
    }
    
    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
        ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
        ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
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

}
