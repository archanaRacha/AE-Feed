//
//  CacheFeedUserCaseTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 23/04/24.
//

import XCTest
import AE_Feed

final class CacheFeedUserCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages , [])
    }
    
    func test_save_requestsCacheDeletion(){
        let feed = uniqueImageFeed().models
        let (sut,store) = makeSUT()
        
        sut.save(feed) { _ in }
        XCTAssertEqual(store.receivedMessages , [.deleteCachedFeed])
    }
    func test_save_doesNotRequestCacheInsertionOnDeletionError(){
        let feed = uniqueImageFeed().models
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        sut.save(feed) { _ in }
        store.completeDeletion(with:deletionError)
        XCTAssertEqual(store.receivedMessages , [.deleteCachedFeed])
    }
    
    func test_save_requestNewCacheInsertionWithTimestampOnSucessfulDeletion(){
        let timestamp = Date()
        let feed = uniqueImageFeed()
        let (sut,store) = makeSUT(currentDate: { timestamp })
        sut.save(feed.models) { _ in }
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages , [.deleteCachedFeed,.insert(feed.local, timestamp)])

    }
    func test_save_failsOnDeletionError(){
        let feed = uniqueImageFeed().models
        let (sut,store) = makeSUT()
        let deletionError = anyNSError()
        let exp = expectation(description: "wait for save completion")
        var receivedError:Error?
        sut.save(feed){ result in
            if case let Result.failure(error) = result {
                receivedError = error
            }
            
            exp.fulfill()
        }
        store.completeDeletion(with:deletionError)
        wait(for: [exp],timeout: 1.0)
        XCTAssertEqual(receivedError! as NSError,deletionError)
    }
    func test_save_failsOnInsertionError(){
        let (sut,store) = makeSUT()
        let insertionError = anyNSError()
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with:insertionError )
        }
    }
    func test_save_successdsOnSuccessfulCacheInsertion(){
        let (sut,store) = makeSUT()
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
        
    }
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.saveResults]()
        sut?.save(uniqueImageFeed().models, completion: { receivedResults.append($0)})
        sut = nil
        store.completeDeletion(with:anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated(){
        let store = FeedStoreSpy()
        var sut:LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)
        var receivedResults = [LocalFeedLoader.saveResults]()
        sut?.save(uniqueImageFeed().models, completion: { receivedResults.append($0)})
        store.completeDeletionSuccessfully()
        sut = nil
        store.completeInsertion(with:anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
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
    private func makeSUT(currentDate:@escaping() -> Date = Date.init,file:StaticString = #file, line : UInt = #line) -> (sut:LocalFeedLoader, store: FeedStoreSpy ){
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store:store,currentDate: currentDate)
        trackMemoryLeaks(store,file: file,line: line)
        trackMemoryLeaks(sut,file: file,line: line)
        return (sut, store)
    }
    private func expect(_ sut : LocalFeedLoader, toCompleteWithError expectedError:NSError?,when action: () -> Void,file:StaticString = #file, line : UInt = #line){
        let exp = expectation(description: "wait for save completion")
        var receivedError:Error?
        sut.save(uniqueImageFeed().models){ result in
            if case let Result.failure(error) = result { receivedError = error }
            exp.fulfill()
        }
        action()
        wait(for: [exp],timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?,expectedError,file: file,line: line)
    }

}
