//
//  LoadFeedFromCacheUseCaseTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 08/05/24.
//

import XCTest
import AE_Feed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessageStoreUponCreation() {
        let (_,store) = makeSUT()
        XCTAssertEqual(store.receivedMessages , [])
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
    private class FeedStoreSpy : FeedStore {
        
        enum ReceivedMessage : Equatable {
            case deleteCachedFeed
            case insert([FeedItem],Date)
        }
        private(set) var receivedMessages = [ReceivedMessage]()
        
        private var deletionCompletions = [DeletionCompletion]()
        private var insertionCompletions = [InsertionCompletions]()
        func deleteCacheFeed(completion:@escaping DeletionCompletion){

            deletionCompletions.append(completion)
            receivedMessages.append(.deleteCachedFeed)
        }
        func completeDeletion(with error:Error, at index:Int = 0){
            deletionCompletions[index](error)
        }
        func completeDeletionSuccessfully(at index:Int = 0){
            deletionCompletions[index](nil)
        }
        func insert(_ items : [FeedItem],timestamp: Date,completion:@escaping InsertionCompletions ){
            insertionCompletions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
        }
        func completeInsertion(with error:Error, at index:Int = 0){
            insertionCompletions[index](error)
        }
        func completeInsertionSuccessfully(at index:Int = 0){
            insertionCompletions[index](nil)
        }
    }
}
