//
//  CodableFeedStoreTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 22/05/24.
//

import XCTest
import AE_Feed

class CodableFeedStore : FeedStore{
  
    private struct Cache : Codable {
        let feed :[CodableFeedImage]
        let timestamp: Date
        var localFeed: [LocalFeedImage]{
            return feed.map{$0.local}
        }
    }
    private struct CodableFeedImage: Equatable, Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        public init(image:LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        var local : LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    private let storeURL : URL
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    func retrieve(completion:@escaping RetrievalCompletions) {
        guard let data = try? Data(contentsOf: storeURL) else {return completion(.empty)}
        do{
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        }catch{
            completion(.failure(error))
        }
    }
    
    func insert(_ feed : [LocalFeedImage],timestamp: Date,completion:@escaping InsertionCompletions ){
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(Cache(feed:feed.map(CodableFeedImage.init),timestamp:timestamp))
            try encoded.write(to: storeURL)
            completion(nil)
        }catch{
            completion(error)
        }
    }
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else{
            return completion(nil)
        }
        do{
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        }catch{
            completion(error)
        }
    }
}
final class CodableFeedStoreTests: XCTestCase {

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(cache: (feed,timestamp), to: sut)
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        insert(cache: (feed,timestamp), to: sut)
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificstoreURL()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid data".write(to:storeURL, atomically: false,encoding:.utf8)
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificstoreURL()
        let sut = makeSUT(storeURL: storeURL)
        try! "invalid data".write(to:storeURL, atomically: false,encoding:.utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let firstInsertionError = insert(cache: (uniqueImageFeed().local,Date()),to:sut)
        XCTAssertNil(firstInsertionError,"Expected to insert cache successfully.")
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert(cache:(latestFeed,latestTimestamp),to : sut)
        XCTAssertNil(latestInsertionError,"Expected to override cache successfully.")
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed,timestamp), to: sut)
        XCTAssertNotNil(insertionError,"Expected cache insertion to fail with an error")
    }
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    func test_delete_emptiesPreviouslyInsertedCache(){
        let sut = makeSUT()
        insert(cache: ((uniqueImageFeed().local),Date()), to: sut)
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected non empty cache deletion to succeed")
        expect(sut, toRetrieve: .empty)
    }
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = cachesDirectory()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError,"Expected cache deletion to fail")
        expect(sut, toRetrieve: .empty)
        
    }
    private func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for cache deletion")
        var deletionError :Error?
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    
        setupEmptyStoreState()
    }
    private func undoStoreSideEffects(){
        deleteStoreArtifacts()
    }
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        undoStoreSideEffects()
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
        return sut
        
    }
    @discardableResult
    private func insert(cache:(feed:[LocalFeedImage],timestamp:Date),to sut:FeedStore) -> Error?{
        
        let exp = expectation(description: "wait for cache insertion")
        var insertionError:Error?
        sut.insert(cache.feed,timestamp:cache.timestamp) { receivedInsertionError in
            insertionError = receivedInsertionError
//            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1.0)
        return insertionError
    }
    private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult:RetrieveCachedResult, file:StaticString = #file, line:UInt = #line){
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
    }
    private func expect(_ sut: FeedStore,toRetrieve expectedResult:RetrieveCachedResult,file: StaticString = #file, line : UInt = #line){
        let exp = expectation(description: "Wait for the cache retrieval")
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),(.failure,.failure):
                break
            case let (.found(expected),.found(retrieved)):
                XCTAssertEqual(retrieved.feed, expected.feed,file:file,line:line)
                XCTAssertEqual(retrieved.timestamp , expected.timestamp,file:file,line:line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    private func testSpecificstoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
