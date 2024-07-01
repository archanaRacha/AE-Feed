//
//  FeedStore.swift
//  AE-Feed
//
//  Created by archana racha on 25/04/24.
//

import Foundation

public typealias CachedFeed  = (feed:[LocalFeedImage],timestamp:Date)

public protocol FeedStore {
    typealias DeletionResult = Error?
    typealias DeletionCompletion = (DeletionResult) -> Void
    typealias InsertionResult = Error?
    typealias InsertionCompletions = (InsertionResult) -> Void
    
    typealias RetrievalResult = Result<CachedFeed?,Error>
    typealias RetrievalCompletions = (RetrievalResult) -> Void
    
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
