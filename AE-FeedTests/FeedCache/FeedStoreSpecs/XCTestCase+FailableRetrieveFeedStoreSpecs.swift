//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  AE-FeedTests
//
//  Created by archana racha on 30/05/24.
//

import XCTest
import AE_Feed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {

    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
            expect(sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
        }

    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
