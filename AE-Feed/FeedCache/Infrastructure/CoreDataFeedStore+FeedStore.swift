//
//  CoreDataFeedStore+FeedStore.swift
//  AE-Feed
//
//  Created by archana racha on 15/10/24.
//

import CoreData

extension CoreDataFeedStore:FeedStore{
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    public func insert(_ feed: [AE_Feed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletions) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
            })
        }
    }
    
    public func retrieve(completion: @escaping RetrievalCompletions) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map{
                    CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
        
    }
}
