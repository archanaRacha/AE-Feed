//
//  FeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 09/02/24.
//

import Foundation

enum LoadFeedResult{
    case success([FeedItem])
    case error(Error)
}
protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult)->Void)
}
