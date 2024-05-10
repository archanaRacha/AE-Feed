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
        case insert([FeedImage],Date)
        case retrieve
    }
    private(set) var receivedMessages = [ReceivedMessage]()
    
    private var deletionCompletions = [DeletionCompletion]()
    private var insertionCompletions = [InsertionCompletions]()
    private var retrievalCompletions = [RetrievalCompletions]()
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
    func insert(_ items : [FeedImage],timestamp: Date,completion:@escaping InsertionCompletions ){
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }
    func completeInsertion(with error:Error, at index:Int = 0){
        insertionCompletions[index](error)
    }
    func completeInsertionSuccessfully(at index:Int = 0){
        insertionCompletions[index](nil)
    }
    func retrieve(completion: @escaping RetrievalCompletions) {
        receivedMessages.append(.retrieve)
        retrievalCompletions.append(completion)
    }
    func completeRetrieval(with error:Error, at index:Int = 0){
        retrievalCompletions[index](.failure(error))
    }
    func completeRetrievalWithEmptyCache(at index:Int = 0){
        retrievalCompletions[index](.empty)
    }
    func completeRetrieval(with feed:[LocalFeedImage],timestamp:Date,at index:Int = 0){
        retrievalCompletions[index](.found(feed, timestamp))
    }
}
