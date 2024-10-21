//
//  FeedImageDataCache.swift
//  AE-Feed
//
//  Created by archana racha on 21/10/24.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
