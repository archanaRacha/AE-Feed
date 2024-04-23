//
//  CacheFeedUserCaseTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 23/04/24.
//

import XCTest
import AE_Feed
class LocalFeedLoader{
    private let store: FeedStore
    init(store:FeedStore){
        self.store = store
    }
    func save(_ items : [FeedItem]){
        store.deleteCacheFeed()
    }
}
class FeedStore {
    var deleteCachedFeedCallCount = 0
    func deleteCacheFeed(){
        deleteCachedFeedCallCount += 1
    }
}
final class CacheFeedUserCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion(){
        
        let (sut,store) = makeSUT()
        let items = [uniqueItem(),uniqueItem()]
        sut.save(items)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
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
    
    //MARK: Helpers
    private func makeSUT() -> (sut:LocalFeedLoader, store: FeedStore ){
        let store = FeedStore()
        let sut = LocalFeedLoader(store:store)
        return (sut, store)
    }
    private func uniqueItem() -> FeedItem{
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    private func anyURL() -> URL{
        return URL(string:"http://any-url.com")!
    }
}
