//
//  SharedTestHelpers.swift
//  AE-FeedTests
//
//  Created by archana racha on 21/05/24.
//

import Foundation

func anyNSError() -> NSError{
    return NSError(domain: "any error", code: 0)
}
func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
func anyData() -> Data {
    return Data("any data".utf8)
}


func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let json = ["items": items]
    return try! JSONSerialization.data(withJSONObject: json)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
