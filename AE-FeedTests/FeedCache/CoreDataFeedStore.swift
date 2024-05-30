//
//  CoreDataFeedStore.swift
//  AE-FeedTests
//
//  Created by archana racha on 30/05/24.
//

import Foundation
import AE_Feed

public final class CoreDataFeedStore : FeedStore {
    public init() {}
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    
    public func insert(_ items: [AE_Feed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletions) {
        
    }
    
    public func retrieve(completion: @escaping RetrievalCompletions) {
        completion(.empty)
    }
    
    
}
