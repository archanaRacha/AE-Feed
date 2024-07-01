//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  AE-FeedTests
//
//  Created by archana racha on 30/05/24.
//

import XCTest
import AE_Feed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {

    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)

        XCTAssertNotNil(deletionError, "Expected cache deletion to fail", file: file, line: line)
    }

    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)

        expect(sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
