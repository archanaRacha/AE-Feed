//
//  XCTestCase+FeedStoreSpecs.swift
//  AE-FeedTests
//
//  Created by archana racha on 30/05/24.
//

import XCTest
import AE_Feed

extension FeedStoreSpecs where Self: XCTestCase {

    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieve: .success(.empty), file: file, line: line)
        }
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieveTwice: .success(.empty), file: file, line: line)
        }
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let feed = uniqueImageFeed().local
            let timestamp = Date()

        insert(cache: (feed, timestamp), to: sut)

        expect(sut, toRetrieve: .success(.found(feed: feed, timestamp: timestamp)), file: file, line: line)
        }
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let feed = uniqueImageFeed().local
            let timestamp = Date()

        insert(cache: (feed, timestamp), to: sut)

            expect(sut, toRetrieveTwice: .success(.found(feed: feed, timestamp: timestamp)), file: file, line: line)
        }
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert(cache: (uniqueImageFeed().local, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to insert cache successfully", file: file, line: line)
        }
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut)

        let insertionError = insert(cache: (uniqueImageFeed().local, Date()), to: sut)

            XCTAssertNil(insertionError, "Expected to override cache successfully", file: file, line: line)
        }
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut)

            let latestFeed = uniqueImageFeed().local
            let latestTimestamp = Date()
        insert(cache: (latestFeed, latestTimestamp), to: sut)

        expect(sut, toRetrieve: .success(.found(feed: latestFeed, timestamp: latestTimestamp)), file: file, line: line)
        }
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            let deletionError = deleteCache(from: sut)

            XCTAssertNil(deletionError, "Expected empty cache deletion to succeed", file: file, line: line)
        }
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            deleteCache(from: sut)

            expect(sut, toRetrieve: .success(.empty), file: file, line: line)
        }
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut)

            let deletionError = deleteCache(from: sut)

            XCTAssertNil(deletionError, "Expected non-empty cache deletion to succeed", file: file, line: line)
        }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(cache: (uniqueImageFeed().local, Date()), to: sut)

            deleteCache(from: sut)

            expect(sut, toRetrieve:.success(.empty), file: file, line: line)
        }
    func assertThatSideEffectsRunSerially(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            var completedOperationsInOrder = [XCTestExpectation]()

            let op1 = expectation(description: "Operation 1")
            sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
                completedOperationsInOrder.append(op1)
                op1.fulfill()
            }

            let op2 = expectation(description: "Operation 2")
            sut.deleteCachedFeed { _ in
                completedOperationsInOrder.append(op2)
                op2.fulfill()
            }

            let op3 = expectation(description: "Operation 3")
            sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
                completedOperationsInOrder.append(op3)
                op3.fulfill()
            }

            waitForExpectations(timeout: 5.0)

            XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Expected side-effects to run serially but operations finished in the wrong order", file: file, line: line)
        }

    }
extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(cache:(feed:[LocalFeedImage],timestamp:Date),to sut:FeedStore) -> Error?{
        
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
    @discardableResult
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for cache deletion")
        var deletionError :Error?
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return deletionError
    }
    func expect(_ sut: FeedStore, toRetrieveTwice expectedResult:RetrieveCachedResult, file:StaticString = #file, line:UInt = #line){
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
        expect(sut, toRetrieve: expectedResult,file: file,line: line)
    }
    func expect(_ sut: FeedStore,toRetrieve expectedResult:RetrieveCachedResult,file: StaticString = #file, line : UInt = #line){

        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.empty), .success(.empty)),(.failure,.failure):
                break
            case let (.success(.found(expectedFeed,expectedTimestamp)), .success(.found(retrievedFeed,retrievedTimestamp))):
                XCTAssertEqual(retrievedFeed, expectedFeed,file:file,line:line)
                XCTAssertEqual(retrievedTimestamp , expectedTimestamp,file:file,line:line)
            default:
                XCTFail("Expected to retrieve \(expectedResult), got \(retrievedResult) instead", file: file, line: line)
            }

        }

    }

}
