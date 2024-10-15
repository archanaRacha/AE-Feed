//
//  CoreDataFeedStore.swift
//  AE-FeedTests
//
//  Created by archana racha on 30/05/24.
//

import Foundation
import CoreData

public final class CoreDataFeedStore {
//    public init() {}
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    public init(storeURL : URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CoreDataFeedStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }
   
    func perform(_ action: @escaping(NSManagedObjectContext) -> Void){
        let context = self.context
        context.perform {
            action(context)
        }
    }
}

