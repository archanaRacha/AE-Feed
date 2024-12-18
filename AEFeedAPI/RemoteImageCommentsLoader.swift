//
//  RemoteImageCommentsLoader.swift
//  AEFeedAPI
//
//  Created by archana racha on 18/12/24.
//

import Foundation
import AE_Feed

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: ImageCommentsMapper.map)
    }
}

