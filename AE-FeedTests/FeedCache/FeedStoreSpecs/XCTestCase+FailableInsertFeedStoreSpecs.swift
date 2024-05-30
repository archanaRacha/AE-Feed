//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  AE-FeedTests
//
//  Created by archana racha on 30/05/24.
//

import XCTest
import AE_Feed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {

    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert(cache:(uniqueImageFeed().local, Date()), to: sut)

            XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error", file: file, line: line)
        }

        func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            insert(cache:(uniqueImageFeed().local, Date()), to: sut)

            expect(sut, toRetrieve: .empty, file: file, line: line)
        }

}
