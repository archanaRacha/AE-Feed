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
    
    func test_load_requestsCacheRetrieval(){
        let (sut, store) = makeSUT()
        sut.load(){ _ in }
        XCTAssertEqual(store.receivedMessages , [.retrieve])
    }
    func test_load_failsOnRetrievalError(){
        let (sut, store) = makeSUT()
        
        let retrievalError = anyNSError()
        let exp = expectation(description: "Wait for load completion")
        var receivedError : Error?
        sut.load{ result in
            switch result{
            case let .failure(error):
                receivedError = error
            default :
                XCTFail("Expected failure, got \(String(describing: result)) instead.")
            }
            
            exp.fulfill()
        }
        store.completeRetrieval(with:retrievalError )
        wait(for:[exp],timeout: 1.0)
        XCTAssertEqual(receivedError as NSError? , retrievalError)
    }
    func test_load_deliversNoImagesOnEmptyCache(){
        let (sut, store) = makeSUT()
        let exp = expectation(description: "Wait for load completion")
        var receivedImages : [FeedImage]?
        sut.load{ result in
            switch result {
            case let .success(images):
                receivedImages = images
                break
            default :
                XCTFail("Expected success, got \(String(describing: result)) instead.")
                break
            }

            exp.fulfill()
        }
        store.completeRetrievalWithEmptyCache()
        wait(for:[exp],timeout: 1.0)
        XCTAssertEqual(receivedImages , [])
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
    private func anyNSError() -> NSError{
        return NSError(domain: "any error", code: 0)
    }
    
}


