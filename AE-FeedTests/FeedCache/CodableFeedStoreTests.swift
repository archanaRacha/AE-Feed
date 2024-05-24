//
//  CodableFeedStoreTests.swift
//  AE-FeedTests
//
//  Created by archana racha on 22/05/24.
//

import XCTest
import AE_Feed

class CodableFeedStore {
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
    func retrieve(completion:@escaping FeedStore.RetrievalCompletions) {
        guard let data = try? Data(contentsOf: storeURL) else {return completion(.empty)}
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    func insert(_ feed : [LocalFeedImage],timestamp: Date,completion:@escaping FeedStore.InsertionCompletions ){
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(Cache(feed:feed.map(CodableFeedImage.init),timestamp:timestamp))
        try! encoded.write(to: storeURL)
        completion(nil)
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
    private func makeSUT(file: StaticString = #file, line:UInt = #line) -> CodableFeedStore{
        let storeURL = testSpecificstoreURL()
        let sut = CodableFeedStore(storeURL: storeURL)
        trackMemoryLeaks(sut, file: file,line:line)
        return sut
        
    }
    private func insert(cache:(feed:[LocalFeedImage],timestamp:Date),to sut:CodableFeedStore){
        let exp = expectation(description: "wait for cache insertion")
        sut.insert(cache.feed,timestamp:cache.timestamp) { insertionError in
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1.0)
    }
    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult:RetrieveCachedResult, file:StaticString = #file, line:UInt = #line){
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
    }
    private func expect(_ sut: CodableFeedStore,toRetrieve expectedResult:RetrieveCachedResult,file: StaticString = #file, line : UInt = #line){
        let exp = expectation(description: "Wait for the cache retrieval")
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty):
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
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

}
