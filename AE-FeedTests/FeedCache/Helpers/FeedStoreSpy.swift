//
//  FeedStoreSpy.swift
//  AE-FeedTests
//
//  Created by archana racha on 08/05/24.
//

import Foundation
import AE_Feed

class FeedStoreSpy : FeedStore {
    enum ReceivedMessage : Equatable {
        case deleteCachedFeed
        case insert([FeedItem],Date)
    }
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletions]()
    func deleteCacheFeed(completion:@escaping DeletionCompletion){

        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }
    func completeDeletion(with error:Error, at index:Int = 0){
        deletionCompletions[index](error)
    }
    func completeDeletionSuccessfully(at index:Int = 0){
        deletionCompletions[index](nil)
    }
    func insert(_ items : [FeedItem],timestamp: Date,completion:@escaping InsertionCompletions ){
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    func completeInsertion(with error:Error, at index:Int = 0){
        insertionCompletions[index](error)
    }
    func completeInsertionSuccessfully(at index:Int = 0){
        insertionCompletions[index](nil)
    }
}
