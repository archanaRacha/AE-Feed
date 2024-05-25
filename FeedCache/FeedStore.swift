//
//  FeedStore.swift
//  AE-Feed
//
//  Created by archana racha on 25/04/24.
//

import Foundation
public enum RetrieveCachedResult {
    case empty
    case found(feed:[LocalFeedImage], timestamp:Date)
    case failure(Error)
}
public typealias CachedFeed = (feed:[LocalFeedImage],timestamp:Date)
public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletions = (Error?) -> Void
    typealias RetrievalCompletions = (RetrieveCachedResult) -> Void
    
    ///The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion:@escaping DeletionCompletion)
    
    ///The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ items : [LocalFeedImage],timestamp: Date,completion:@escaping InsertionCompletions )
    
    ///The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion:@escaping RetrievalCompletions)
   
}
