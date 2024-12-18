//
//  RemoteFeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 12/02/24.
//

import Foundation
import AE_Feed

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}

