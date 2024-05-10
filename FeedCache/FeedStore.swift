//
//  FeedStore.swift
//  AE-Feed
//
//  Created by archana racha on 25/04/24.
//

import Foundation
public enum RetrieveCachedResult {
    case empty
    case found(_ feed:[LocalFeedImage], _ timestamp:Date)
    case failure(Error)
}
public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletions = (Error?) -> Void
    typealias RetrievalCompletions = (RetrieveCachedResult) -> Void
    func deleteCacheFeed(completion:@escaping DeletionCompletion)
    func insert(_ items : [FeedImage],timestamp: Date,completion:@escaping InsertionCompletions )
    func retrieve(completion:@escaping RetrievalCompletions)
   
}
