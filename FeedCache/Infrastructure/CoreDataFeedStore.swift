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
            do {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
                completion(FeedStore.DeletionResult.success(()))
            }catch {
                completion(FeedStore.DeletionResult.failure(error))
            }
        }
    }
    public func insert(_ feed: [AE_Feed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletions) {
        perform { context in
            do {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)
                try context.save()
                completion(FeedStore.InsertionResult.success(()))
            }catch{
                completion(FeedStore.InsertionResult.failure(error))
            }
        }
        
    }
    public func retrieve(completion: @escaping RetrievalCompletions) {
        perform { context in
            completion(Result(catching: {
                if let cache = try ManagedCache.find(in: context) {
                    return CachedFeed(feed: cache.localFeed, timestamp: cache.timestamp)
                }else{
                    return .none 
                }
            }))
        }
        
    }
    private func perform(_ action: @escaping(NSManagedObjectContext) -> Void){
        let context = self.context
        context.perform {
            action(context)
        }
    }
}

