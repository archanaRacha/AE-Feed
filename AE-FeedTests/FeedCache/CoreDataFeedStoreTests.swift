//
//  CoreDataFeedStoreTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 30/05/24.
//

import XCTest
import AE_Feed

final class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        
    }
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        
    }
    func test_insert_deliversNoErrorOnEmptyCache() {
        
    }
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        
    }
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        
    }
    func test_delete_deliversNoErrorOnEmptyCache() {
        
    }
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        
    }
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        
    }
    func test_delete_emptiesPreviouslyInsertedCache() {
        
    }
    
    func test_storeSideEffects_runSerially() {
        
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
    private func makeSUT(file: StaticString = #file, line : UInt = #line) -> FeedStore{
//        let sut = CoreDataFeedStore()
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let sut = try! CoreDataFeedStore(bundle: storeBundle)
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
