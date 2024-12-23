//
//  AE_FeedAPIEndToEndTests.swift
//  AE_FeedAPIEndToEndTests
//
//  Created by archana racha on 10/03/24.
//

import XCTest
import AE_Feed
import AEFeedAPI

final class AE_FeedAPIEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGetFeedResult_matchesFixedTestAccountData() {
        
        switch getFeedResult() {
        case .success(let array):
            XCTAssertEqual(array.count, 8, "Expected 8 items in the test account feed")
            XCTAssertEqual(array[0], expectedImage(at :0))
            XCTAssertEqual(array[1], expectedImage(at :1))
            XCTAssertEqual(array[2], expectedImage(at :2))
            XCTAssertEqual(array[3], expectedImage(at :3))
            XCTAssertEqual(array[4], expectedImage(at :4))
            XCTAssertEqual(array[5], expectedImage(at :5))
            XCTAssertEqual(array[6], expectedImage(at :6))
            XCTAssertEqual(array[7], expectedImage(at :7))
        case .failure(let error):
                XCTFail("Expected successful feed result, got \(error) instead")
      
        case .none:
            XCTFail("Expected successfull feed result, got no result instead")
        }
    }
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
            switch getFeedImageDataResult() {
            case let .success(data)?:
                XCTAssertFalse(data.isEmpty, "Expected non-empty image data")

            case let .failure(error)?:
                XCTFail("Expected successful image data result, got \(error) instead")

            default:
                XCTFail("Expected successful image data result, got no result instead")
            }
        }
    //MARK: Helper functions
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> Swift.Result<[FeedImage], Error>? {
        
        let loader = RemoteLoader(url: feedTestServerURL, client: ephemeralClient(), mapper: FeedItemsMapper.map)
        trackMemoryLeaks(loader,file: file,line: line)
        let exp = expectation(description: "wait for load completion")
        var receivedResult: Swift.Result<[FeedImage], Error>?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 10.0)
        return receivedResult
    }
    private func getFeedImageDataResult(file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader.Result? {
        
        
        let client = ephemeralClient()
        let url = feedTestServerURL.appendingPathComponent("73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        let exp = expectation(description: "Wait for load completion")
        var receivedResult: FeedImageDataLoader.Result?
        client.get(from: url) { result in
                   receivedResult = result.flatMap { (data, response) in
                       do {
                           return .success(try FeedImageDataMapper.map(data, from: response))
                       } catch {
                           return .failure(error)
                       }
                   }
                   exp.fulfill()
               }
        wait(for: [exp], timeout: 10.0)

        return receivedResult
    }
    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackMemoryLeaks(client, file: file, line: line)
        return client
    }
    private var feedTestServerURL: URL {
            return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        }
    private func expectedImage(at index:Int) -> FeedImage {
        return FeedImage(id: id(at : index) , description: description(at : index), location: location(at : index), url: imageURL(at : index))
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
