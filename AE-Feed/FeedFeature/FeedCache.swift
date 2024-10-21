//
//  FeedCache.swift
//  AE-Feed
//
//  Created by archana racha on 21/10/24.
//

import Foundation


public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
