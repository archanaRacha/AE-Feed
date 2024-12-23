//
//  LocalFeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 25/04/24.
//

import Foundation

public final class LocalFeedLoader : FeedCache{
    private let store: FeedStore
    private let currentDate: () -> Date
//    private let cachePolicy = FeedCachePolicy()
    public init(store:FeedStore,currentDate : @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
    
}

extension LocalFeedLoader{
    public typealias saveResults = Result<Void,Error>
    public func save(_ feed : [FeedImage],completion:@escaping(saveResults) -> Void){
        store.deleteCachedFeed {[weak self] deletionResult in
            guard let self = self else {return}
            switch deletionResult {
            case .success:
                self.cache(feed,with:completion)
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    private func cache(_ feed:[FeedImage],with completion:@escaping (saveResults) -> Void){
        store.insert(feed.toLocal(),timestamp: currentDate()){ [weak self] insertionResult in
            guard self != nil else {return}
            completion(insertionResult)
        }
    }
}

    
extension LocalFeedLoader {
    public typealias LoadResult = Swift.Result<[FeedImage], Error>
    public func load(completion:@escaping(LoadResult) -> Void){
        store.retrieve { [weak self] result in
            guard let self = self else{return}
            switch result {
            case let .failure(error):
                completion(.failure(error))
                break
            case let .success(.some(cache)) where FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                completion(.success(cache.feed.toModels()))
                break
            case .success:
                completion(.success([]))
                break
            }
        }
    }
}

extension LocalFeedLoader{
    public typealias ValidationResult = Result<Void, Error>
    public func validateCache(completion: @escaping (ValidationResult) -> Void)
    {
        store.retrieve { [weak self] result in
            guard let self = self else{return }
            switch result {
            case .failure(_):
                self.store.deleteCachedFeed (  completion : completion )
                break
            case let .success(.some(cache)) where !FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed (  completion : completion )
                break
            case .success:
                completion(.success(()))
            }
            
            
        }
        
    }
    
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id : $0.id, description:$0.description, location:$0.location , url: $0.url)
        }
    }
}
private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id : $0.id, description:$0.description, location:$0.location , url: $0.url)
        }
    }
}


