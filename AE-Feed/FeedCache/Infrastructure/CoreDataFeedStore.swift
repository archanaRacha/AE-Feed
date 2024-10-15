//
//  CoreDataFeedStore.swift
//  AE-FeedTests
//
//  Created by archana racha on 30/05/24.
//

import Foundation
import CoreData

public final class CoreDataFeedStore : FeedStore {
//    public init() {}
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    public init(storeURL : URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CoreDataFeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
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
    func perform(_ action: @escaping(NSManagedObjectContext) -> Void){
        let context = self.context
        context.perform {
            action(context)
        }
    }
}

