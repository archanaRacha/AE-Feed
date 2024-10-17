//
//  FeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 09/02/24.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping(Result)->Void)
}
