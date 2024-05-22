//
//  LocalFeedLoader.swift
//  AE-Feed
//
//  Created by archana racha on 25/04/24.
//

import Foundation

public final class LocalFeedLoader{
    private let store: FeedStore
    private let currentDate: () -> Date
//    private let cachePolicy = FeedCachePolicy()
    public init(store:FeedStore,currentDate : @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
    
}

extension LocalFeedLoader{
    public typealias saveResults = Error?
    public func save(_ items : [FeedImage],completion:@escaping(saveResults) -> Void){
        store.deleteCacheFeed {[weak self] error in
            guard let self = self else {return}
            if let cacheDeletionerror = error {
                completion(cacheDeletionerror)
            }else{
                self.cache(items,with:completion)
                
            }
            
        }
    }
    private func cache(_ items:[FeedImage],with completion:@escaping (saveResults) -> Void){
        store.insert(items,timestamp: currentDate()){ [weak self] error in
            guard self != nil else {return}
            completion(error)
        }
    }
}

    
extension LocalFeedLoader : FeedLoader {
    public typealias LoadResult = LoadFeedResult
    public func load(completion:@escaping(LoadResult) -> Void){
        store.retrieve { [weak self] retrieveCachedResult in
            guard let self = self else{return}
            switch retrieveCachedResult{
            case let .failure(error):
                completion(.failure(error))
                break
            case .found(feed: let feed, timestamp: let timestamp) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toModels()))
                break
            case .found,.empty:
                completion(.success([]))
                break
            }
        }
    }
}

extension LocalFeedLoader{
    public func validateCache(){
        store.retrieve { [weak self] result in
            guard let self = self else{return }
            switch result{
            case .failure(_):
                self.store.deleteCacheFeed { _ in }
                break
            case let .found(_,timestamp) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCacheFeed { _ in }
                break
            case .found, .empty: break
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


