//
//  CodableFeedStoreTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 22/05/24.
//

import XCTest
import AE_Feed


final class CodableFeedStoreTests: XCTestCase,FailableFeedStore {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
        
    }
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
      
    }
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificstoreURL()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid data".write(to:storeURL, atomically: false,encoding:.utf8)
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificstoreURL()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid data".write(to:storeURL, atomically: false,encoding:.utf8)
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
        
    }
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
       
    }
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
       
    }
 
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
       
    }
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
      
    }
    func test_delete_deliversNoErrorOnNonEmptyCache(){
        let sut = makeSUT()
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
       
    }
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
       
    }

    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
        
        
    }
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
        
    }
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    
        setupEmptyStoreState()
    }
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        undoStoreSideEffects()
    }
    func test_storeSideEffects_runSerially(){
        let sut = makeSUT()
        assertThatSideEffectsRunSerially(on: sut)
        
    }
    
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    private func undoStoreSideEffects(){
        deleteStoreArtifacts()
    }
    

    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificstoreURL())
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
    // _ MARK: Helpers
    private func makeSUT(storeURL:URL? = nil, file: StaticString = #file, line:UInt = #line) -> FeedStore{
        let storeURL = storeURL ?? testSpecificstoreURL()
        let sut = CodableFeedStore(storeURL: storeURL)
        trackMemoryLeaks(sut, file: file,line:line)
        return sut as FeedStore
        
    }
  
    private func testSpecificstoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
