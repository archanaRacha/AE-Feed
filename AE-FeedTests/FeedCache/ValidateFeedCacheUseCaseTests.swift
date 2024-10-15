//
//  ValidateFeedCacheUseCaseTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 21/05/24.
//

import XCTest
import AE_Feed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages , [])
    }
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        sut.validateCache { _ in }
        let retrievalError = anyNSError()
        store.completeRetrieval(with: retrievalError)
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    func test_validateCache_doesNotdeletesCacheOnEmptyCache() {
        let (sut, store) = makeSUT()
        sut.validateCache { _ in }
        store.completeRetrievalWithEmptyCache()
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    func test_validateCache_doesNotdeletesOnNonExpirationCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds:1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache{ _ in}
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    func test_validateCache_deletesCacheOnCacheExpiration() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    func test_validateCache_deletesCacheOnExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds:-1)
        let (sut, store) = makeSUT(currentDate: {fixedCurrentDate})
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        XCTAssertEqual(store.receivedMessages, [.retrieve,.deleteCachedFeed])
    }
    func test_validateCache_deosNotDeliverInvalidCacheAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        sut?.validateCache { _ in }
        sut = nil
        store.completeRetrieval(with: anyNSError())
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    //MARK: Helpers
    private func makeSUT(currentDate:@escaping() -> Date = Date.init,file:StaticString = #file, line : UInt = #line) -> (sut:LocalFeedLoader, store: FeedStoreSpy ){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store,currentDate: currentDate)
        trackMemoryLeaks(store,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut, store)
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
