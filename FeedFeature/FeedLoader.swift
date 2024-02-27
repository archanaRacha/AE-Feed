//
//  FeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 09/02/24.
//

import Foundation

public enum LoadFeedResult{
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult)->Void)
}
