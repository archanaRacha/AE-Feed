//
//  XCTestCase+MemoryLeakTracking.swift
//  AE-FeedTests
//
//  Created by archana racha on 06/03/24.
//

import XCTest

extension XCTestCase{
     func trackMemoryLeaks(_ instance:AnyObject,file:StaticString = #file,line:UInt = #line){
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance,"instance should have been deallocated. Potential memory leak.",file: file, line:  line)
        }
    }
}
