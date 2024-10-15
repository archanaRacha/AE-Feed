//
//  AE_FeedCacheIntegrationTests.swift
//  AE_FeedCacheIntegrationTests
//
//  Created by archana racha on 04/06/24.
//

import XCTest
import AE_Feed

final class AE_FeedCacheIntegrationTests: XCTestCase {

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeFeedLoader()
        expect(sut,toLoad: [])
    }
    func test_load_deliversItemsSavedOnASeparateInstance(){
        let sutToPerformSave = makeFeedLoader()
        let sutToPerformLoad = makeFeedLoader()
        let feed = uniqueImageFeed().models
        save(feed, with:sutToPerformSave)
        expect(sutToPerformLoad, toLoad: feed)
    }
    func test_save_orverridesItemsSavedOnASeparateInstance(){
        let sutToPerformFirstSave = makeFeedLoader()
        let sutToPerformLastSave = makeFeedLoader()
        let sutToPerformLoad = makeFeedLoader()
        let firstFeed = uniqueImageFeed().models
        let latestFeed = uniqueImageFeed().models
        save(firstFeed, with:sutToPerformFirstSave)
        save(latestFeed,with: sutToPerformLastSave)
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
        
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        setupEmptyStoreState()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        undoStoreSideEffects()
    }
    private func setupEmptyStoreState(){
        deleteStoreArtifacts()
    }
    private func undoStoreSideEffects(){
        deleteStoreArtifacts()
    }
    

    private func deleteStoreArtifacts(){
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
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
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    // MARK: - LocalFeedImageDataLoader Tests
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
            let imageLoaderToPerformSave = makeImageLoader()
            let imageLoaderToPerformLoad = makeImageLoader()
            let feedLoader = makeFeedLoader()
            let image = uniqueImage()
            let dataToSave = anyData()

            save([image], with: feedLoader)
            save(dataToSave, for: image.url, with: imageLoaderToPerformSave)

            expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
        }
    // MARK: Helpers
    private func makeFeedLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {

            let storeURL = testSpecificStoreURL()
            let store = try! CoreDataFeedStore(storeURL: storeURL)
            let sut = LocalFeedLoader(store: store, currentDate: Date.init)
            trackMemoryLeaks(store, file: file, line: line)
            trackMemoryLeaks(sut, file: file, line: line)
            return sut
        }
    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        trackMemoryLeaks(store, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    private func save(_ feed:[FeedImage], with loader:LocalFeedLoader,file:StaticString = #file,line:UInt = #line){
        let saveExp = expectation(description: "wait for save comppletion")
        loader.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for:[saveExp],timeout: 1.0)
        
    }
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line){
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed,file:file,line: line)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp],timeout: 1.0)
    }
    private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }

    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(loadedData):
                XCTAssertEqual(loadedData, expectedData, file: file, line: line)

            case let .failure(error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }

    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

}
