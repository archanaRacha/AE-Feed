//
//  CoreDataFeedStore.swift
//  AE-FeedTests
//
//  Created by archana racha on 30/05/24.
//

import Foundation
import AE_Feed
import CoreData

public final class CoreDataFeedStore : FeedStore {
//    public init() {}
    private let container: NSPersistentContainer
    public init(bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CoreDataFeedStore", in: bundle)
    }
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
    public func insert(_ items: [AE_Feed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletions) {
        
    }
    public func retrieve(completion: @escaping RetrievalCompletions) {
        completion(.empty)
    }
}
private extension  NSPersistentContainer {
    enum LoadingError : Error {
        case modelNotFound
        case failedToLoadPersistentStores(Error)
    }
    static func load(modelName name: String, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else{
            throw LoadingError.modelNotFound
        }
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        var loadError: Error?
        
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        return container
    }
}
private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle.url(forResource: name, withExtension: "momd").flatMap { NSManagedObjectModel(contentsOf: $0)}
    }
}
private class ManagedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedCache
}
