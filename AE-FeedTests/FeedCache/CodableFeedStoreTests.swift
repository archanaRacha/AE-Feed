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
    private let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
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
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default: XCTFail("Expeccted empty result, got \(result) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1.0)
    }
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { firstresult in
            sut.retrieve { secondresult in
                switch (firstresult,secondresult) {
                case (.empty,.empty):
                    break
                default: XCTFail("Expeccted retrieving twice empty cache to deliver same empty result, got \(firstresult) and \(secondresult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp],timeout: 1.0)
    }
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "wait for cache retrieval")
        sut.insert(feed,timestamp:timestamp) { insertionError in
            XCTAssertNil(insertionError,"Expected feed to be inserted successfully")
            sut.retrieve { retrieveResult in
                switch retrieveResult {
                case let .found(feed: retrivedFeed, timestamp: retrievedTimestamp):
                    XCTAssertEqual(retrivedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                    break
                default: XCTFail("Expeccted found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instread")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp],timeout: 1.0)
    }
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
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
    private func makeSUT(file: StaticString = #file, line:UInt= #line) -> CodableFeedStore{
        let sut = CodableFeedStore()
        trackMemoryLeaks(sut, file: file,line:line)
        return sut
        
    }

}
