//
//  FeedStore.swift
//  AE-Feed
//
//  Created by archana racha on 25/04/24.
//

import Foundation
public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletions = (Error?) -> Void
    func deleteCacheFeed(completion:@escaping DeletionCompletion)
    func insert(_ items : [FeedItem],timestamp: Date,completion:@escaping InsertionCompletions )
}
