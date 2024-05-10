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
    public typealias saveResults = Error?
    public typealias LoadResult = LoadFeedResult
    public init(store:FeedStore,currentDate : @escaping () -> Date){
        self.store = store
        self.currentDate = currentDate
    }
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
    public func load(completion:@escaping(LoadResult) -> Void){
        store.retrieve { retrieveCachedResult in
            switch retrieveCachedResult{
            case .empty:
                completion(.success([]))
                break
            case let .found(feed,_):
                completion(.success(feed.toModels()))
                break
            case let .failure(error):
                completion(.failure(error))
                break
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


